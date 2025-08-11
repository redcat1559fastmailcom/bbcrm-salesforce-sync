# BBCRM to Salesforce Migration Pipeline

This repository contains a robust, auditable ETL pipeline designed to migrate constituent data from Blackbaud CRM (BBCRM) to Salesforce. It leverages SQL Server Integration Services (SSIS), Python scripts, and custom staging tables to ensure referential integrity, incremental sync, and error handling across platforms.

## 🔧 Features

- ✅ GUID-based key mapping between BBCRM and Salesforce custom objects  
- ✅ Incremental sync using `DateChanged` fields and audit logs  
- ✅ Staging architecture for repeatable, scalable ETL  
- ✅ OAuth2 authentication and API integration with Salesforce  
- ✅ Python utilities for bulk mock data generation and validation  
- ✅ SSIS packages with built-in error handling and logging

## 📁 Repository Structure


