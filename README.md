# Listin - Collaborative Shop Lists
Welcome to the Listin - Collaborative Shop Lists repository! This project is a collaborative shopping list app built using Flutter and Firebase, allowing users to create and manage shopping lists with friends and family.

# Features
Create Lists: Users can create shopping lists with items they need to buy.
Real-time Updates: Changes made to a list by any collaborator are instantly synced and visible.
User Authentication: Secure user authentication powered by Firebase Authentication.
Cloud Firestore Integration: Data storage and synchronization are handled by Firebase Cloud Firestore.

# Prerequisites
Flutter SDK installed on your machine.
Firebase project set up with Firestore and Authentication services enabled.

# Installation
Clone this repository:
```
git clone https://github.com/jpcarvalhodev/listin.git
```
Navigate into the project directory:
```
cd listin
```
Run the following command to get the dependencies:
```
flutter pub get
```
Connect your device or emulator.

Run the app:
```
flutter run
```

# Usage
Register or log in with your account.
Create a new shopping list
Add items to the list and mark them as purchased when bought.
Enjoy real-time updates as you interact with the lists.

# Folder Structure
```
lib/
|-- models/
|   |-- shopping_list.dart
|   |-- user.dart
|-- screens/
|   |-- add_item_screen.dart
|   |-- create_list_screen.dart
|   |-- home_screen.dart
|   |-- login_screen.dart
|   |-- register_screen.dart
|   |-- shopping_list_detail_screen.dart
|-- services/
|   |-- auth_service.dart
|   |-- database_service.dart
|   |-- storage_service.dart
|-- widgets/
|   |-- custom_list_tile.dart
|   |-- list_item_tile.dart
|-- main.dart
```

# Contribution
Contributions are welcome! If you have any suggestions for improvements or new features, feel free to open an issue or submit a pull request.
