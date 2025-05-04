This repository contains an automated SQL script designed to create and populate a database for analyzing campaign performance from lead generation data.

## 🧠 What It Does

- Creates a MySQL database called `campaign_analysis`
- Defines a table `campaign_performance` with fields to track:
  - Monthly lead and campaign data
  - Gross vs Net financial metrics (profit, cost, revenue)
  - Lead acceptance and error rates
  - Ping/post ratios and bid data
- Loads data from a CSV file into the table for further analysis

## 📁 Files

- `Lead Proper Analysis SQL Automated.sql` – Main SQL script to:
  - Create the database and table
  - Load your campaign report into MySQL for analysis

## ✅ Requirements

- MySQL Server (recommended 8.0 or later)
- A campaign data CSV file in the expected format
- Properly configured `secure_file_priv` in MySQL (to allow `LOAD DATA INFILE`)

## 📌 How to Use

1. **Start MySQL** and log in to your server.
2. **Set up CSV import permissions**:
   - Place your CSV file in the folder allowed by `secure_file_priv`
   - Adjust the file path in the script if needed
3. **Run the script** using your preferred SQL client or terminal.

## 🧪 Sample Query Ideas

- Analyze top performing campaigns by net profit
- Visualize monthly trends in lead volume
- Compare gross vs. net margins over time

## 🛠 Notes

- Update the CSV file path in the script as needed.
- If using a cloud-based or managed MySQL service, you may need to import the data using a GUI like MySQL Workbench or phpMyAdmin.

## 📬 Feedback

Have suggestions or want to collaborate? Feel free to open an issue or pull request!
