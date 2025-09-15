fn main() {
    println!("hello world");
}

#[cfg(test)]
mod test {
    use n_vm::in_vm;

    #[test]
    #[in_vm]
    fn biscuit() {
        assert_eq!(2 + 2, 4);
        panic!("oh no");
    }
}
