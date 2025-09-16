fn main() {
    println!("hello world");
}

#[cfg(test)]
mod test {
    use n_vm::in_vm;

    #[test]
    #[in_vm]
    fn science_time() {
        assert_eq!(2 + 2, 4);
        assert!(false, "oh no!");
    }
}
