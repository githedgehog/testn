fn main() {
    println!("hello world");
}

#[cfg(test)]
mod test {
    use n_vm::in_vm;

    #[test]
    #[in_vm]
    fn test_which_runs_in_vm() {
        assert_eq!(2 + 2, 4);
    }

    #[should_panic]
    #[test]
    #[in_vm]
    fn test_which_runs_in_vm_control() {
        assert_eq!(2 + 2, 4);
        assert!(false, "deliberate panic");
    }

    #[test]
    fn test_which_does_not_run_in_vm() {
        assert_eq!(2 + 2, 4);
    }

    #[should_panic]
    #[test]
    fn test_which_does_not_run_in_vm_control() {
        assert_eq!(2 + 2, 4);
        assert!(false, "deliberate panic");
    }
}
