fn main() {
    let hello = "Hello world";
    let say_hello = |hi: &str| -> bool {
        println!("{}", hi);
        true
    };
    
    say_hello("hey");
}
