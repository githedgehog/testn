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
        // assert!(false, "oh no!");
    }

    #[test]
    #[in_vm]
    fn science_time_control() {
        assert_eq!(2 + 2, 4);
        assert!(false, "oh no!");
    }

    #[test]
    fn test_which_does_not_run_in_vm() {
        assert_eq!(2 + 2, 4);
    }

    #[test]
    fn test_which_does_not_run_in_vm_control() {
        assert_eq!(2 + 2, 4);
        assert!(false, "oh no!");
    }
}
