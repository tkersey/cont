import Darwin
public struct Cont<R, A> {
    let run: (@escaping (A) -> R) -> R
    
    init(_ run: @escaping (@escaping (A) -> R) -> R) {
        self.run = run
    }
}

extension Cont {
    public static func pure (a: A) -> Self {
        .init { k in k(a) }
    }
}

public func bind<R, A, B>(c: Cont<R, A>, f: @escaping (A) -> Cont<R, B>) -> Cont<R, B> {
    .init { k in c.run { a in f(a).run(k) } }
}

public func fmap<R, A, B>(c: Cont<R, A>, f: @escaping (A) -> B) -> Cont<R, B> {
    .init { k in c.run { a in k(f(a)) } }
}

public func callCC<R, A, B>(_ f: @escaping (@escaping (A) -> Cont<R, B>) -> Cont<R, A>) -> Cont<R, A> {
    .init { k in f { a in Cont { _ in k(a) } }.run(k) }
}
