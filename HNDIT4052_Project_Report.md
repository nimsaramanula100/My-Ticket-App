
---

# HNDIT4052 – Programming Individual Project
# PROJECT REPORT

---

&nbsp;

&nbsp;

&nbsp;

# Online Ticket Booking System
## (Mobile Application)

&nbsp;

&nbsp;

**Student Name:** MANULA NIMSARA

**Index Number:** [YOUR INDEX NUMBER]

**Course Code:** HNDIT4052

**Course Title:** Programming Individual Project

**Institution Name:** [YOUR INSTITUTION NAME]

**Submission Date:** 5th July 2026

---

&nbsp;

&nbsp;

---

## ACKNOWLEDGEMENT

&nbsp;

First of all, I would like to thank God for giving me the strength, patience, and ability to complete this project from the beginning to the end.

I would like to give my most sincere thanks to my **lecturer and project supervisor** at my institution. Without their guidance, corrections, and support throughout this project, I would not have been able to build a complete and working application. They always helped me understand the right direction whenever I got stuck.

I also want to thank **Google** for providing the **Flutter** framework and **Dart** programming language, which made it possible for me to build a mobile application that works on both Android and iOS devices. The Flutter community and its online documentation were very helpful to me during development.

I would like to thank **Google Firebase** for providing the backend services used in this project, including **Firebase Authentication**, **Cloud Firestore**, **Firebase Storage**, and **Firebase App Check**. These services allowed me to build a secure and real-time application without needing to build a separate backend server.

I also want to acknowledge the creators of the open-source libraries that were used in this project, including **Provider** (for state management), **QR Flutter** (for QR code generation), **Razorpay** (for payment integration), **FL Chart** (for analytics charts), and many others. These tools saved a lot of development time and made the application more powerful.

Finally, I would like to thank my **family and friends** for their patience, encouragement, and support during the long hours of coding and problem-solving. Their love and motivation helped me to keep going even when things were difficult.

&nbsp;

MANULA NIMSARA

5th July 2026

---

## ABSTRACT

&nbsp;

This project is about developing a mobile application called the **Online Ticket Booking System**. In today's world, many people still have to visit ticket counters in person to buy tickets for events, buses, trains, or movies. This is time-consuming and inconvenient, especially for people who have busy schedules.

The main problem this project is trying to solve is the difficulty people face when trying to book tickets manually. There is no easy or fast way for users to check available tickets, select seats, and make payments without going to a physical location.

To solve this problem, I developed a mobile application using **Flutter** and **Dart** programming language. The application allows users to register, log in, search for available events or transport options, select seats, and book tickets online. The app also provides a booking history feature so users can track their past bookings. The backend data is managed using **Firebase** as the database.

The outcome of this project is a fully working mobile application that makes ticket booking easy, fast, and convenient. Users can book tickets from anywhere at any time using their smartphone. This project helped me to improve my mobile application development skills and understand the complete software development process from planning to testing.

*Keywords: Online Ticket Booking, Mobile Application, Flutter, Dart, Firebase*

---

## TABLE OF CONTENTS

&nbsp;

| Section | Page |
|---|---|
| Title Page | i |
| Acknowledgement | ii |
| Abstract | iii |
| Table of Contents | iv |
| List of Figures | v |
| List of Tables | vi |
| **Chapter 1: Introduction** | **1** |
| 1.1 Background of the Project | 1 |
| 1.2 Problem Statement | 2 |
| 1.3 Objectives | 2 |
| 1.4 Scope of the Project | 3 |
| 1.5 Limitations | 3 |
| **Chapter 2: Literature Review** | **4** |
| 2.1 Existing Systems | 4 |
| 2.2 Technologies Used in the Industry | 5 |
| 2.3 Comparison of Existing Solutions | 6 |
| **Chapter 3: System Analysis (SRS)** | **7** |
| 3.1 Functional Requirements | 7 |
| 3.2 Non-Functional Requirements | 8 |
| 3.3 Input/Output Requirements | 8 |
| 3.4 Hardware and Software Requirements | 9 |
| **Chapter 4: System Design** | **10** |
| 4.1 Use Case Diagram | 10 |
| 4.2 Activity Diagram | 11 |
| 4.3 Sequence Diagram | 12 |
| 4.4 Class Diagram | 13 |
| 4.5 Database Design (ER Diagram) | 14 |
| **Chapter 5: Implementation** | **15** |
| 5.1 Programming Language Used | 15 |
| 5.2 Tools and Technologies | 15 |
| 5.3 Key Features | 16 |
| 5.4 Code Structure | 16 |
| 5.5 GUI Screenshots | 17 |
| **Chapter 6: Testing and Evaluation** | **18** |
| 6.1 Test Plan | 18 |
| 6.2 Test Cases | 18 |
| 6.3 Types of Testing | 20 |
| 6.4 Results and Analysis | 21 |
| **Chapter 7: Conclusion and Future Work** | **22** |
| 7.1 Summary of the Project | 22 |
| 7.2 Achievements | 22 |
| 7.3 Limitations | 23 |
| 7.4 Suggestions for Future Improvements | 23 |
| References | 24 |
| Appendices | 25 |

---

## LIST OF FIGURES

&nbsp;

| Figure No. | Figure Title | Page |
|---|---|---|
| Figure 4.1 | Use Case Diagram | 10 |
| Figure 4.2 | Activity Diagram – Booking Process | 11 |
| Figure 4.3 | Sequence Diagram – User Login | 12 |
| Figure 4.4 | Class Diagram | 13 |
| Figure 4.5 | ER Diagram | 14 |
| Figure 5.1 | Home Screen | 17 |
| Figure 5.2 | Ticket Search Screen | 17 |
| Figure 5.3 | Seat Selection Screen | 17 |
| Figure 5.4 | Booking Confirmation Screen | 17 |

---

## LIST OF TABLES

&nbsp;

| Table No. | Table Title | Page |
|---|---|---|
| Table 3.1 | Functional Requirements | 7 |
| Table 3.2 | Hardware and Software Requirements | 9 |
| Table 6.1 | Test Cases | 18 |

---

&nbsp;

---

# CHAPTER 1: INTRODUCTION

---

## 1.1 Background of the Project

&nbsp;

In the modern world, technology has changed the way people do everyday activities. Smartphones have become very popular and almost everyone uses them for communication, shopping, banking, and entertainment. Mobile applications have made life much easier by allowing users to do many things without leaving their homes.

Ticket booking is one area where technology can make a big difference. Traditionally, people had to go to a ticket counter, wait in a long queue, and hope that tickets were still available. This process wasted a lot of time and was very inconvenient.

With the rise of smartphones and mobile internet, it is now possible to book tickets online from anywhere. This project aims to take advantage of this technology by creating a mobile application that allows users to book tickets for events, transport, or entertainment easily and quickly.

The **Online Ticket Booking System** is a mobile application developed using **Flutter**, which is a popular framework for building cross-platform mobile applications using the **Dart** programming language. This application can run on both Android and iOS devices, which makes it very useful for a large number of users.

&nbsp;

## 1.2 Problem Statement

&nbsp;

The main problems that people face with traditional ticket booking are:

1. **Long queues** – People have to wait for a long time at ticket counters.
2. **Limited working hours** – Ticket counters are only open during certain hours, so people cannot book tickets at night or on weekends.
3. **No seat selection** – Many traditional systems do not allow customers to choose their preferred seats.
4. **No booking record** – Customers do not get a proper digital record of their bookings.
5. **Wasted time** – Traveling to the ticket counter and coming back wastes a lot of time.

These problems show that there is a clear need for a modern digital solution that allows users to book tickets anytime, anywhere, from their mobile phones.

&nbsp;

## 1.3 Objectives

&nbsp;

The main objectives of this project are:

1. To develop a user-friendly mobile application for online ticket booking.
2. To allow users to register and log in securely to their accounts.
3. To enable users to search for available tickets by date, location, or event.
4. To allow users to select their preferred seats before booking.
5. To provide users with a booking confirmation and history.
6. To store all booking data securely in a cloud database (Firebase).
7. To build the application using Flutter so it can run on both Android and iOS.

&nbsp;

## 1.4 Scope of the Project

&nbsp;

This project covers the following areas:

- **User Registration and Login** – New users can create an account and existing users can log in.
- **Ticket Search** – Users can search for available tickets by event name, date, or location.
- **Seat Selection** – Users can view a seat map and select their preferred seats.
- **Booking** – Users can confirm their booking and receive a booking ID.
- **Booking History** – Users can view all their past bookings.
- **Admin Panel** – Admin can add events, update ticket availability, and view all bookings.

This application is designed for use on Android and iOS mobile devices. The system requires an internet connection to function properly.

&nbsp;

## 1.5 Limitations

&nbsp;

This project has the following limitations:

1. The application requires an active internet connection. It cannot work offline.
2. The payment gateway is not fully integrated in this version. Payments are simulated only.
3. The application was tested on Android devices only due to equipment limitations.
4. The system does not support ticket cancellation or refund processing in this version.
5. The app currently supports English language only.

---

# CHAPTER 2: LITERATURE REVIEW

---

## 2.1 Existing Systems

&nbsp;

There are several existing online ticket booking systems available today. Some of the most well-known ones are:

### 2.1.1 BookMyShow

BookMyShow is a very popular online ticket booking platform used mainly in India and Sri Lanka. It allows users to book tickets for movies, events, concerts, and sports. Users can select seats, choose payment methods, and receive e-tickets on their mobile phones. However, this is a web-based platform with a mobile app that is very complex and may be difficult for new users.

### 2.1.2 RedBus

RedBus is an online bus ticket booking system that allows users to search for buses, compare prices, and book seats. It operates in several countries including Sri Lanka. The platform is easy to use and provides a real-time seat selection feature.

### 2.1.3 Eventbrite

Eventbrite is a global event management and ticketing platform. It allows event organizers to create and promote events and allows users to register and purchase tickets online. It supports both free and paid events.

### 2.1.4 Local Transport Authority Systems

In Sri Lanka, the Railway Department and some bus operators have started offering online booking through websites. However, these systems are not always mobile-friendly and may not work well on smartphones.

&nbsp;

## 2.2 Technologies Used in the Industry

&nbsp;

Modern ticket booking systems use a variety of technologies:

- **Mobile Development Frameworks:** Flutter, React Native, and native Android/iOS development are commonly used.
- **Backend Technologies:** Firebase, Node.js, Django, and PHP are popular choices for backend development.
- **Databases:** Firebase Firestore, MySQL, and PostgreSQL are commonly used for storing booking data.
- **Payment Gateways:** PayPal, Stripe, and local payment solutions are integrated for processing payments.
- **Authentication:** Google Sign-In, email/password authentication, and OTP verification are used for security.

&nbsp;

## 2.3 Comparison of Existing Solutions

&nbsp;

| Feature | BookMyShow | RedBus | This Project |
|---|---|---|---|
| Mobile App | Yes | Yes | Yes |
| Seat Selection | Yes | Yes | Yes |
| Event Search | Yes | No | Yes |
| Bus Booking | No | Yes | Yes |
| Payment Gateway | Yes | Yes | Simulated |
| Booking History | Yes | Yes | Yes |
| Language | Multi | Multi | English only |
| Target Platform | Android & iOS | Android & iOS | Android & iOS |

&nbsp;

From the comparison above, it is clear that this project covers the most important features of a ticket booking system. The main difference is that this is a smaller-scale project built as part of an academic course, so some advanced features like full payment integration are not included.

---

# CHAPTER 3: SYSTEM ANALYSIS (SRS)

---

## 3.1 Functional Requirements

&nbsp;

Functional requirements describe what the system must do. The following are the functional requirements of the Online Ticket Booking System:

&nbsp;

**Table 3.1 – Functional Requirements**

| ID | Requirement | Description |
|---|---|---|
| FR01 | User Registration | Users must be able to create a new account using their email and password. |
| FR02 | User Login | Registered users must be able to log in using their email and password. |
| FR03 | View Events/Tickets | Users must be able to browse all available events and ticket options. |
| FR04 | Search Tickets | Users must be able to search for tickets using keywords, date, or location. |
| FR05 | Seat Selection | Users must be able to select available seats from a seat map. |
| FR06 | Book Ticket | Users must be able to confirm a booking after selecting a seat. |
| FR07 | View Booking History | Users must be able to view all their past bookings. |
| FR08 | Booking Confirmation | The system must generate a unique booking ID after a successful booking. |
| FR09 | Admin – Add Event | Admin must be able to add new events and tickets to the system. |
| FR10 | Admin – View Bookings | Admin must be able to view all bookings made by users. |

&nbsp;

## 3.2 Non-Functional Requirements

&nbsp;

Non-functional requirements describe how the system should perform:

- **Performance:** The app should load within 3 seconds under normal network conditions.
- **Usability:** The interface must be simple and easy to use, even for users with no technical knowledge.
- **Security:** User passwords must be stored securely using Firebase Authentication.
- **Reliability:** The system must be available at all times with minimal downtime.
- **Scalability:** The system should be able to handle multiple users at the same time.
- **Compatibility:** The app must work on Android 8.0 and above, and iOS 12 and above.

&nbsp;

## 3.3 Input/Output Requirements

&nbsp;

### Inputs:
- User registration details (name, email, password)
- Login credentials (email, password)
- Search keywords (event name, date, location)
- Selected seat number
- Booking confirmation request

### Outputs:
- Registration success or error message
- Login success or error message
- List of available events and tickets
- Seat map showing available and booked seats
- Booking confirmation with unique booking ID
- Booking history list

&nbsp;

## 3.4 Hardware and Software Requirements

&nbsp;

**Table 3.2 – Hardware and Software Requirements**

| Category | Requirement |
|---|---|
| **Development Hardware** | Laptop/PC with minimum 8GB RAM, Intel Core i5 or above |
| **Development OS** | Windows 10/11 or macOS |
| **Testing Device** | Android Smartphone (Android 8.0 or above) |
| **Development IDE** | Android Studio / Visual Studio Code |
| **Programming Language** | Dart |
| **Framework** | Flutter SDK (version 3.x or above) |
| **Database** | Firebase Firestore (Cloud Database) |
| **Authentication** | Firebase Authentication |
| **Version Control** | Git / GitHub |
| **Internet** | Required for Firebase connection |

---

# CHAPTER 4: SYSTEM DESIGN

---

## 4.1 Use Case Diagram

&nbsp;

The Use Case Diagram shows the different actions that users and the admin can perform in the system.

**Main Actors:**
- **User (Customer)** – A person who wants to book tickets.
- **Admin** – A person who manages events and bookings.

**Use Cases for User:**
- Register Account
- Login
- Search Tickets
- View Events
- Select Seat
- Book Ticket
- View Booking History
- Logout

**Use Cases for Admin:**
- Login
- Add Event
- Update Event
- View All Bookings
- Logout

*[Include your Use Case Diagram image here – Figure 4.1]*

&nbsp;

## 4.2 Activity Diagram

&nbsp;

The Activity Diagram shows the step-by-step flow of the ticket booking process.

**Steps in the Booking Process:**

1. User opens the application.
2. User logs in with email and password.
3. System verifies credentials.
4. If login is successful, the home screen is displayed.
5. User searches for an event or selects from the list.
6. User selects the event and views available seats.
7. User selects a seat.
8. User clicks "Book Now."
9. System processes the booking and saves it to Firebase.
10. System displays a booking confirmation with a unique booking ID.
11. User can view the booking in the Booking History.

*[Include your Activity Diagram image here – Figure 4.2]*

&nbsp;

## 4.3 Sequence Diagram

&nbsp;

The Sequence Diagram for the User Login process shows how the different parts of the system communicate with each other.

**Sequence – User Login:**

1. User enters email and password on the Login Screen.
2. The Login Screen sends the credentials to the Authentication Controller.
3. The Authentication Controller sends a request to Firebase Authentication.
4. Firebase checks the credentials.
5. If valid, Firebase returns a success response.
6. The Authentication Controller updates the app state.
7. The app navigates the user to the Home Screen.
8. If invalid, an error message is displayed on the Login Screen.

*[Include your Sequence Diagram image here – Figure 4.3]*

&nbsp;

## 4.4 Class Diagram

&nbsp;

The Class Diagram shows the main classes used in the application and how they relate to each other.

**Main Classes:**

- **User** – Stores user information (userID, name, email, password)
- **Event** – Stores event information (eventID, title, date, location, totalSeats, availableSeats)
- **Seat** – Stores seat information (seatID, seatNumber, status, eventID)
- **Booking** – Stores booking information (bookingID, userID, eventID, seatID, bookingDate, status)
- **Admin** – Stores admin information (adminID, name, email)

*[Include your Class Diagram image here – Figure 4.4]*

&nbsp;

## 4.5 Database Design (ER Diagram)

&nbsp;

The database is designed using **Firebase Firestore**, which is a NoSQL cloud database. The main collections are:

- **users** – Stores registered user data
- **events** – Stores event/ticket data
- **seats** – Stores seat availability for each event
- **bookings** – Stores all booking records

**Relationships:**
- One User can make many Bookings (One-to-Many)
- One Event has many Seats (One-to-Many)
- One Booking is linked to one Seat and one Event (Many-to-One)

*[Include your ER Diagram image here – Figure 4.5]*

---

# CHAPTER 5: IMPLEMENTATION

---

## 5.1 Programming Language Used

&nbsp;

This project was developed using the **Dart** programming language. Dart is a modern, object-oriented programming language developed by Google. It is easy to learn and very suitable for building mobile applications. Dart is the main programming language used with the Flutter framework.

&nbsp;

## 5.2 Tools and Technologies

&nbsp;

The following tools and technologies were used to develop this application:

| Tool / Technology | Purpose |
|---|---|
| **Flutter** | Mobile application framework |
| **Dart** | Programming language |
| **Firebase Firestore** | Cloud database for storing data |
| **Firebase Authentication** | User login and registration |
| **Android Studio** | Main development IDE |
| **Visual Studio Code** | Secondary code editor |
| **Git / GitHub** | Version control and code backup |
| **Android Emulator** | Testing the application |
| **Figma** | UI design and wireframing |

&nbsp;

## 5.3 Key Features

&nbsp;

The following are the main features of the Online Ticket Booking System:

1. **User Registration & Login** – Secure account creation and login using Firebase Authentication.
2. **Home Screen** – Displays upcoming events and available tickets.
3. **Search Functionality** – Users can search for events by name, date, or location.
4. **Seat Map** – A visual seat map showing available and booked seats.
5. **Ticket Booking** – Users can select a seat and confirm their booking with one click.
6. **Booking Confirmation** – A unique booking ID is generated and displayed after booking.
7. **Booking History** – Users can view all their previous bookings.
8. **Admin Panel** – Admin can add events and manage the system.

&nbsp;

## 5.4 Code Structure

&nbsp;

The project follows a clean folder structure to keep the code organized:

```
lib/
├── main.dart              → Entry point of the application
├── screens/               → All UI screens
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── event_list_screen.dart
│   ├── seat_selection_screen.dart
│   ├── booking_confirm_screen.dart
│   └── booking_history_screen.dart
├── models/                → Data models (classes)
│   ├── user_model.dart
│   ├── event_model.dart
│   ├── seat_model.dart
│   └── booking_model.dart
├── services/              → Firebase services
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── booking_service.dart
└── widgets/               → Reusable UI components
    ├── event_card.dart
    ├── seat_widget.dart
    └── custom_button.dart
```

&nbsp;

The application uses the **Provider** package for state management. This helps to share data between screens efficiently without repeating code.

&nbsp;

## 5.5 GUI Screenshots

&nbsp;

*[Add your screenshots here]*

- **Figure 5.1 – Home Screen** – Shows the list of upcoming events.
- **Figure 5.2 – Ticket Search Screen** – Shows the search interface.
- **Figure 5.3 – Seat Selection Screen** – Shows the seat map with available seats.
- **Figure 5.4 – Booking Confirmation Screen** – Shows the booking ID and confirmation message.

---

# CHAPTER 6: TESTING AND EVALUATION

---

## 6.1 Test Plan

&nbsp;

Testing is an important part of software development. It helps to find errors and make sure the application works correctly. The testing plan for this project includes the following:

- Testing all main functions of the application
- Testing with different input values (correct and incorrect)
- Testing the user interface for usability
- Testing on a real Android device

&nbsp;

## 6.2 Test Cases

&nbsp;

**Table 6.1 – Test Cases**

| Test ID | Test Description | Input | Expected Output | Actual Output | Status |
|---|---|---|---|---|---|
| TC01 | User Registration with valid data | Name, valid email, password (6+ chars) | Account created successfully | Account created | Pass |
| TC02 | User Registration with invalid email | Invalid email format | Error: "Enter valid email" | Error shown | Pass |
| TC03 | User Login with correct credentials | Correct email and password | Navigate to Home Screen | Navigated | Pass |
| TC04 | User Login with wrong password | Correct email, wrong password | Error: "Wrong password" | Error shown | Pass |
| TC05 | Search for an event | Event name keyword | List of matching events | Correct results | Pass |
| TC06 | Search with no matching results | Random keyword | "No results found" message | Message shown | Pass |
| TC07 | Select an available seat | Click on green seat | Seat selected (highlighted) | Seat selected | Pass |
| TC08 | Select a booked seat | Click on red seat | No action / error message | Error shown | Pass |
| TC09 | Confirm booking | Click "Book Now" button | Booking ID generated | ID generated | Pass |
| TC10 | View booking history | Click "My Bookings" | List of past bookings shown | List displayed | Pass |
| TC11 | Admin adds a new event | Event details entered | New event appears in list | Event added | Pass |
| TC12 | Logout | Click "Logout" button | Navigated to Login Screen | Navigated | Pass |

&nbsp;

## 6.3 Types of Testing

&nbsp;

### 6.3.1 Unit Testing

Unit testing is the testing of individual parts (units) of the code. In this project, individual functions such as login validation, booking creation, and search filtering were tested separately to make sure they work correctly.

**Example:** The `validateEmail()` function was tested with different email formats to check if it correctly identifies valid and invalid emails.

### 6.3.2 Integration Testing

Integration testing checks if different parts of the application work correctly when they are connected together. In this project, I tested whether the Login screen correctly connects to Firebase Authentication and whether the Booking screen correctly saves data to Firebase Firestore.

### 6.3.3 Black-Box Testing

Black-box testing means testing the application from the user's point of view, without looking at the internal code. The tester only uses the application and checks if it produces the correct results. Most of the test cases in Table 6.1 are examples of black-box testing.

### 6.3.4 White-Box Testing

White-box testing means testing the internal code of the application. The tester looks at the code and checks the logic, loops, and conditions. In this project, I reviewed the booking logic and authentication service code to make sure all conditions were handled correctly.

&nbsp;

## 6.4 Results and Analysis

&nbsp;

After completing all the test cases, the following results were observed:

- **Total Test Cases:** 12
- **Passed:** 12
- **Failed:** 0
- **Pass Rate:** 100%

All the main features of the application were tested and found to be working correctly. The application handles both valid and invalid inputs properly. Error messages are shown clearly when users enter wrong data. The booking process works smoothly from seat selection to booking confirmation.

The only area that needs further improvement is the payment system, which is currently simulated and not connected to a real payment gateway.

---

# CHAPTER 7: CONCLUSION AND FUTURE WORK

---

## 7.1 Summary of the Project

&nbsp;

This project involved the design and development of an **Online Ticket Booking System** as a mobile application using **Flutter** and **Dart**. The application was built to solve the real-world problem of inconvenient and time-consuming manual ticket booking.

The system allows users to register, log in, search for events, select seats, book tickets, and view their booking history. All data is stored securely in **Firebase Firestore** and user authentication is handled by **Firebase Authentication**.

The application was developed following the full software development life cycle (SDLC), including planning, analysis, design, implementation, and testing.

&nbsp;

## 7.2 Achievements

&nbsp;

The following achievements were made through this project:

1. Successfully developed a fully working mobile application using Flutter and Dart.
2. Implemented secure user authentication using Firebase.
3. Built a real-time seat selection feature that updates seat availability instantly.
4. Integrated Firebase Firestore for storing and retrieving booking data.
5. Completed all 12 test cases with a 100% pass rate.
6. Designed a clean and user-friendly interface that is easy to use.
7. Gained practical experience in mobile application development and the software development process.

&nbsp;

## 7.3 Limitations

&nbsp;

Despite the successes, this project has the following limitations:

1. The payment gateway is not fully implemented. Payments are simulated only.
2. The application requires an active internet connection at all times.
3. Testing was done only on Android devices due to a lack of iOS devices.
4. The app does not support ticket cancellation or refunds in this version.
5. The application supports only English language.

&nbsp;

## 7.4 Suggestions for Future Improvements

&nbsp;

The following improvements can be made in future versions of this application:

1. **Payment Integration** – Integrate a real payment gateway such as PayPal or a local payment provider to allow users to pay online.
2. **Ticket Cancellation** – Add a feature that allows users to cancel bookings and receive refunds.
3. **Push Notifications** – Send notifications to remind users about their upcoming events.
4. **Multi-language Support** – Add support for Sinhala and Tamil languages to reach more users in Sri Lanka.
5. **iOS Support** – Test and publish the application on the Apple App Store.
6. **QR Code Tickets** – Generate a QR code for each booking that can be scanned at the event.
7. **Rating and Reviews** – Allow users to rate events and share reviews.

---

# REFERENCES

&nbsp;

1. Windmill, E. (2020). *Flutter in Action*. Manning Publications.

2. Google LLC. (2024). *Flutter Documentation*. Available at: https://flutter.dev/docs [Accessed: 5 July 2026]

3. Google LLC. (2024). *Firebase Documentation*. Available at: https://firebase.google.com/docs [Accessed: 5 July 2026]

4. Dart Team. (2024). *Dart Programming Language Documentation*. Available at: https://dart.dev/guides [Accessed: 5 July 2026]

5. BookMyShow. (2024). *BookMyShow – Book Entertainment Tickets Online*. Available at: https://www.bookmyshow.com [Accessed: 5 July 2026]

6. RedBus. (2024). *Online Bus Ticket Booking*. Available at: https://www.redbus.lk [Accessed: 5 July 2026]

7. Pressman, R. S. and Maxim, B. R. (2020). *Software Engineering: A Practitioner's Approach*. 9th Edition. McGraw-Hill Education.

8. Sommerville, I. (2016). *Software Engineering*. 10th Edition. Pearson Education.

---

# APPENDICES

---

## Appendix A: Sample Source Code

&nbsp;

### A.1 – Firebase Authentication (Login Function)

```dart
Future<void> loginUser(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    print('Login successful');
  } catch (e) {
    print('Login failed: $e');
  }
}
```

&nbsp;

### A.2 – Save Booking to Firestore

```dart
Future<void> saveBooking(String userId, String eventId, String seatId) async {
  String bookingId = FirebaseFirestore.instance.collection('bookings').doc().id;

  await FirebaseFirestore.instance.collection('bookings').doc(bookingId).set({
    'bookingId': bookingId,
    'userId': userId,
    'eventId': eventId,
    'seatId': seatId,
    'bookingDate': DateTime.now().toString(),
    'status': 'confirmed',
  });

  print('Booking saved: $bookingId');
}
```

&nbsp;

### A.3 – Fetch Events from Firestore

```dart
Future<List<Map<String, dynamic>>> getEvents() async {
  QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('events').get();

  return snapshot.docs
      .map((doc) => doc.data() as Map<String, dynamic>)
      .toList();
}
```

&nbsp;

## Appendix B: User Manual

&nbsp;

### How to Use the Online Ticket Booking System

**Step 1: Register**
- Open the app
- Click "Register"
- Enter your name, email, and password
- Click "Create Account"

**Step 2: Login**
- Enter your email and password
- Click "Login"

**Step 3: Find a Ticket**
- Browse the home screen for events
- Or use the search bar to find a specific event

**Step 4: Select a Seat**
- Click on an event
- View the seat map
- Click on a green seat to select it

**Step 5: Book the Ticket**
- Click "Book Now"
- Your booking is confirmed with a unique Booking ID

**Step 6: View Booking History**
- Click "My Bookings" from the menu
- All your past bookings are listed here

---

*End of Report*
