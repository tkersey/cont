public struct IxCont<R, O, A> {
    public let run : (@escaping (A) -> O) -> R

    init(_ run : @escaping (@escaping (A) -> O) -> R) {
        self.run = run
    }
}

public func run<R, O>(_ a : IxCont<R, O, O>) -> R {
    a.run { $0 }
}

public func pure<R, A>(_ x : A) -> IxCont<R, R, A> {
    .init { $0(x) }
}

public func ap<R, I, O, A, B>(f : IxCont<R, I, (A) -> B>, a : IxCont<I, O, A>) -> IxCont<R, O, B> {
    .init { k in f.run { g in a.run { k(g($0)) } } }
}

public func bind<R, I, O, A, B>(a : IxCont<R, I, A>, f : @escaping (A) -> IxCont<I, O, B>) -> IxCont<R, O, B> {
    .init { k in a.run { f($0).run(k) } }
}

public func join<R, I, O, A>(_ a : IxCont<R, I, IxCont<I, O, A>>) -> IxCont<R, O, A> {
    .init { k in a.run { $0.run(k) } }
}

public func callCC<R, O, A, B>(_ f : @escaping ((A) -> IxCont<O, O, B>) -> IxCont<R, O, A>) -> IxCont<R, O, A> {
    .init({ k in (f { x in .init { _ in k(x) } }).run(k) })
}

public func shift<R, I, J, O, A>(_ f : @escaping ((A) -> IxCont<I, I, O>) -> IxCont<R, J, J>) -> IxCont<R, O, A> {
    .init { k in run(f { pure(k($0)) }) }
}

public func reset<R, O, A>(_ a : IxCont<A, O, O>) -> IxCont<R, R, A> {
    pure(run(a))
}
