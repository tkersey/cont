import Darwin
public struct Cont<R, A> {
    let run: (@escaping (A) -> R) -> R
    
    init(_ run: @escaping (@escaping (A) -> R) -> R) {
        self.run = run
    }
}

public func run<R>(_ a: Cont<R, R>) -> R {
    a.run { $0 }
}

public func pure<R, A>(_ a: A) -> Cont<R, A> {
    .init { $0(a) }
}

public func bind<R, A, B>(_ c: Cont<R, A>, f: @escaping (A) -> Cont<R, B>) -> Cont<R, B> {
    .init { k in c.run { f($0).run(k) } }
}

public func fmap<R, A, B>(_ c: Cont<R, A>, f: @escaping (A) -> B) -> Cont<R, B> {
    .init { k in c.run { k(f($0)) } }
}

public func callCC<R, A, B>(_ f: @escaping (@escaping (A) -> Cont<R, B>) -> Cont<R, A>) -> Cont<R, A> {
    .init { k in f { a in .init { _ in k(a) } }.run(k) }
}

public func reset<R, S>(_ a: Cont<R, R>) -> Cont<S, R> {
    pure(run(a))
}

public func shift<R, S, A>(_ f : @escaping ((A) -> Cont<S, R>) -> Cont<R, R>) -> Cont<R, A> {
    .init { k in run(f { pure(k($0)) }) }
}
