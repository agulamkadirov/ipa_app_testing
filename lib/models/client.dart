class Client {
    int? id;
    String name;
    String phone;
    DateTime date;
    String notes;
    String address;
    bool completed = false;

    Client({
        this.id,
        required this.name,
        required this.phone,
        required this.date,
        this.notes = '',
        required this.address,
    });

    static int compareByDate(Client a, Client b) =>
      a.date.compareTo(b.date);
}
