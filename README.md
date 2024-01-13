# Dark-Matter

Application demonstrating infinite scroll in a tableView

The application operates on the following model: there is a database that stores trillions of date measurements.

The device displays measurements as follows: initially, it requests a certain amount of measurements from the database, and as the user scrolls to the end of the measurements, the device fetches a bit more from the database. At the same time, it removes an equal amount of measurements from the beginning of the list.

Thus, the device retains only a strictly defined number of measurements at any given time, which helps prevent memory overflow.
