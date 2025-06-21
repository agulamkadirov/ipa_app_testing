class Client {
    String name;
    String phone;
    DateTime date;
    String notes;
    String address;
    bool completed = false;

    Client({
        required this.name,
        required this.phone,
        required this.date,
        this.notes = '',
        required this.address,
    });

    static int compareByDate(Client a, Client b) =>
      a.date.compareTo(b.date);
}
