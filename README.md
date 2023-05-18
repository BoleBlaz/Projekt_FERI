# Website Location Tracker

Welcome to the Website Location Tracker project! This project aims to provide a platform where users can track their location and access relevant information. This readme file will guide you through the setup and usage of the application.

## Table of Contents
1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Database Setup](#database-setup)
5. [Scraper Configuration](#scraper-configuration)
6. [Usage](#usage)
7. [Contributing](#contributing)
8. [License](#license)

## Introduction
The Website Location Tracker is a web application that allows users to track their location and provides access to relevant information. It includes a registration and login system for user authentication. The application utilizes a database hosted on cPanel using phpMyAdmin. Additionally, it features a scraper that retrieves data from the website [http://portal.drsc.si/traffic/loclist_si.htm](http://portal.drsc.si/traffic/loclist_si.htm).

The website is accessible at: [https://beoflere.com/FERI_projekt/app/index.php](https://beoflere.com/FERI_projekt/app/index.php), and a list of all projects can be found at: [https://beoflere.com/](https://beoflere.com/).

## Prerequisites
Before proceeding with the installation, ensure that you have the following prerequisites:
- Web server (e.g., Apache, Nginx)
- PHP (version 7.0 or higher)
- MySQL database
- cPanel hosting with phpMyAdmin access

## Installation
To install the Website Location Tracker, follow these steps:
1. Clone the project repository: `git clone https://github.com/your-username/website-location-tracker.git`
2. Move the project files to your web server's document root directory.
3. Ensure that the necessary permissions are set for the files and directories.
4. Open the `config.php` file and update the database connection details, including the host, database name, username, and password.
5. Save the changes.

## Database Setup
1. Access your cPanel and navigate to phpMyAdmin.
2. Create a new database for the Website Location Tracker.
3. Import the `database.sql` file from the project repository into the newly created database. This will set up the necessary tables.

## Scraper Configuration
The scraper is responsible for retrieving data from [http://portal.drsc.si/traffic/loclist_si.htm](http://portal.drsc.si/traffic/loclist_si.htm). To configure and use the scraper, follow these steps:
1. Open the `scraper.php` file in the project directory.
2. Update the scraper logic as needed, considering the structure and content of the target website.
3. Save the changes.

## Usage
To use the Website Location Tracker, follow these steps:
1. Access the website at [https://beoflere.com/FERI_projekt/app/index.php](https://beoflere.com/FERI_projekt/app/index.php).
2. Register a new account or log in if you already have an account.
3. Once logged in, you can track your location and access relevant information.
4. Explore the various features of the application, such as searching for locations and viewing detailed information.

## Contributing
Contributions to the Website Location Tracker project are welcome! If you find any bugs, issues, or have suggestions for improvements, please open an issue or submit a pull request in the project repository.

## License
The Website Location Tracker project is licensed under the [MIT License](https://opensource.org/licenses/MIT). You are free to modify and distribute the codebase. However, please ensure to include the original license file in your distributions.

