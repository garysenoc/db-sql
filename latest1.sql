/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.7.2-MariaDB, for Win64 (AMD64)
--
-- Host: 192.168.240.30    Database: app_database
-- ------------------------------------------------------
-- Server version	10.11.13-MariaDB-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `adjustment_settings`
--

DROP TABLE IF EXISTS `adjustment_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `adjustment_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `adjustment_type_id` int(11) NOT NULL,
  `adjustment_name` varchar(255) NOT NULL,
  `is_included_by_default` tinyint(1) DEFAULT 1,
  `category` enum('discount','credit','insurance','other') DEFAULT 'other',
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `adjustment_type_id` (`adjustment_type_id`),
  KEY `idx_adjustment_type_settings` (`adjustment_type_id`),
  KEY `idx_adjustment_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `audit_adjustments`
--

DROP TABLE IF EXISTS `audit_adjustments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_adjustments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `audit_run_id` int(11) NOT NULL COMMENT 'Reference to quarterly_audit_runs table',
  `provider_id` int(11) NOT NULL COMMENT 'Reference to providers table',
  `batch_run_id` varchar(36) DEFAULT NULL COMMENT 'Batch run where adjustment was applied',
  `category` varchar(50) NOT NULL COMMENT 'Category: hygiene, restorative, ortho, production, etc.',
  `adjustment_amount` decimal(10,2) NOT NULL COMMENT 'Positive = owed to provider, Negative = overpaid',
  `quarter` int(11) NOT NULL COMMENT 'Quarter number (1-4)',
  `year` int(11) NOT NULL COMMENT 'Year',
  `applied_at` timestamp NULL DEFAULT NULL COMMENT 'Timestamp when applied to batch',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `production_difference` decimal(10,2) DEFAULT NULL,
  `commission_rate` decimal(5,4) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_audit_provider_category` (`audit_run_id`,`provider_id`,`category`),
  KEY `idx_audit_run` (`audit_run_id`),
  KEY `idx_provider` (`provider_id`),
  KEY `idx_batch_run` (`batch_run_id`),
  KEY `idx_category` (`category`),
  KEY `idx_applied_at` (`applied_at`),
  KEY `idx_provider_unapplied` (`provider_id`,`applied_at`),
  CONSTRAINT `fk_aa_audit_run` FOREIGN KEY (`audit_run_id`) REFERENCES `quarterly_audit_runs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_aa_provider` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=114 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tracks quarterly audit adjustments and their application to batch payroll runs';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL COMMENT 'User who performed the action (NULL for system actions)',
  `action_type` varchar(50) NOT NULL COMMENT 'Type of action performed (login, logout, data_access, permission_change)',
  `resource_type` varchar(50) DEFAULT NULL COMMENT 'Type of resource affected (user, provider, payroll, etc.)',
  `resource_id` varchar(100) DEFAULT NULL COMMENT 'ID of affected resource',
  `details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Additional action details including before/after states' CHECK (json_valid(`details`)),
  `ip_address` varchar(45) DEFAULT NULL COMMENT 'Client IP address',
  `user_agent` text DEFAULT NULL COMMENT 'Client user agent string',
  `session_id` varchar(128) DEFAULT NULL COMMENT 'Session ID for correlation',
  `timestamp` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_audit` (`user_id`,`timestamp`),
  KEY `idx_action_audit` (`action_type`,`timestamp`),
  KEY `idx_resource_audit` (`resource_type`,`resource_id`),
  KEY `idx_timestamp_audit` (`timestamp`),
  KEY `idx_session_audit` (`session_id`,`timestamp`),
  KEY `idx_audit_logs_timestamp` (`timestamp`),
  KEY `idx_audit_logs_user_timestamp` (`user_id`,`timestamp`),
  CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2385 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Audit trail for all system actions and data access (HIPAA compliance)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `batch_payroll_reports`
--

DROP TABLE IF EXISTS `batch_payroll_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `batch_payroll_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `batch_run_id` varchar(36) NOT NULL,
  `provider_id` int(11) NOT NULL,
  `provider_name` varchar(255) NOT NULL,
  `provider_type` varchar(100) NOT NULL,
  `open_dental_provnum` int(11) DEFAULT NULL,
  `pay_period_start` date NOT NULL,
  `pay_period_end` date NOT NULL,
  `total_pay` decimal(10,2) DEFAULT 0.00,
  `base_pay` decimal(10,2) DEFAULT 0.00,
  `bonuses` decimal(10,2) DEFAULT 0.00,
  `deductions` decimal(10,2) DEFAULT 0.00,
  `calculation_status` enum('pending','processing','completed','failed') NOT NULL DEFAULT 'pending',
  `error_message` text DEFAULT NULL,
  `error_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`error_details`)),
  `calculation_started_at` timestamp NULL DEFAULT NULL,
  `calculation_completed_at` timestamp NULL DEFAULT NULL,
  `calculation_duration_ms` int(11) DEFAULT NULL,
  `provider_specific_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`provider_specific_data`)),
  `calculation_metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`calculation_metadata`)),
  `adapter_version` varchar(50) DEFAULT '1.0.0',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `pdf_file_path` varchar(500) DEFAULT NULL COMMENT 'Relative path to generated PDF file (e.g., "Employees/Dr_Smith_Payroll.pdf")',
  `pdf_generation_started_at` timestamp NULL DEFAULT NULL COMMENT 'When PDF generation began for this provider',
  `pdf_generation_completed_at` timestamp NULL DEFAULT NULL COMMENT 'When PDF generation completed (success or failure)',
  `pdf_generation_error` text DEFAULT NULL COMMENT 'Detailed error information for failed PDF generation',
  `pdf_generation_status` enum('pending','processing','completed','failed') DEFAULT 'pending' COMMENT 'Status of PDF generation for this individual provider report',
  PRIMARY KEY (`id`),
  KEY `idx_batch_reports_batch_run` (`batch_run_id`),
  KEY `idx_batch_reports_provider` (`provider_id`),
  KEY `idx_batch_reports_status` (`calculation_status`),
  KEY `idx_batch_reports_processed_at` (`calculation_completed_at`),
  KEY `idx_batch_reports_pdf_timing` (`pdf_generation_started_at`,`pdf_generation_completed_at`),
  KEY `idx_batch_reports_pdf_status` (`batch_run_id`,`pdf_generation_status`),
  KEY `idx_batch_reports_provider_category` (`batch_run_id`,`provider_type`),
  KEY `idx_batch_reports_file_path` (`pdf_file_path`),
  KEY `idx_batch_reports_pdf_errors` (`pdf_generation_status`,`pdf_generation_error`(255))
) ENGINE=InnoDB AUTO_INCREMENT=1121 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `batch_payroll_runs`
--

DROP TABLE IF EXISTS `batch_payroll_runs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `batch_payroll_runs` (
  `id` varchar(36) NOT NULL,
  `requested_by` int(11) DEFAULT NULL,
  `requested_at` timestamp NULL DEFAULT current_timestamp(),
  `pay_period_start` date NOT NULL,
  `pay_period_end` date NOT NULL,
  `provider_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`provider_ids`)),
  `total_providers` int(11) NOT NULL,
  `status` enum('queued','processing','completed','failed','cancelled') NOT NULL DEFAULT 'queued',
  `providers_processed` int(11) DEFAULT 0,
  `providers_failed` int(11) DEFAULT 0,
  `current_provider_id` int(11) DEFAULT NULL,
  `current_provider_name` varchar(255) DEFAULT NULL,
  `started_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `estimated_completion` timestamp NULL DEFAULT NULL,
  `options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`options`)),
  `fail_fast` tinyint(1) DEFAULT 1,
  `total_compensation` decimal(10,2) DEFAULT NULL,
  `total_base_pay` decimal(10,2) DEFAULT NULL,
  `total_bonuses` decimal(10,2) DEFAULT NULL,
  `total_deductions` decimal(10,2) DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `error_provider_id` int(11) DEFAULT NULL,
  `error_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`error_details`)),
  `processing_duration_ms` int(11) DEFAULT NULL,
  `avg_provider_duration_ms` int(11) DEFAULT NULL,
  `memory_usage_mb` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `summary_pdf_path` varchar(500) DEFAULT NULL COMMENT 'Relative path to generated payroll summary PDF',
  `batch_zip_path` varchar(500) DEFAULT NULL COMMENT 'Relative path to generated ZIP archive containing all PDFs',
  `pdf_generation_started_at` timestamp NULL DEFAULT NULL COMMENT 'When PDF generation phase began for this batch',
  `pdf_generation_completed_at` timestamp NULL DEFAULT NULL COMMENT 'When PDF generation phase completed for this batch',
  `pdf_generation_duration_ms` int(11) DEFAULT NULL COMMENT 'Total PDF generation time in milliseconds',
  `pdf_error_message` text DEFAULT NULL COMMENT 'Error message if PDF generation failed',
  `pdf_error_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Detailed PDF generation error information' CHECK (json_valid(`pdf_error_details`)),
  `total_pdfs_generated` int(11) DEFAULT 0 COMMENT 'Count of successfully generated individual PDFs',
  `total_pdf_failures` int(11) DEFAULT 0 COMMENT 'Count of failed individual PDF generations',
  `pdf_generation_status` enum('pending','processing','completed','failed') DEFAULT 'pending' COMMENT 'Overall PDF generation status for the entire batch',
  `report_type` enum('regular','quarterly_audit') DEFAULT 'regular' COMMENT 'Type of report',
  `audit_adjustments_applied` tinyint(1) DEFAULT 0 COMMENT 'Whether audit adjustments were included',
  `audit_run_id` int(11) DEFAULT NULL COMMENT 'Reference to quarterly_audit_runs',
  PRIMARY KEY (`id`),
  KEY `idx_batch_status` (`status`),
  KEY `idx_batch_requested_at` (`requested_at`),
  KEY `idx_batch_pay_period` (`pay_period_start`,`pay_period_end`),
  KEY `idx_batch_user` (`requested_by`),
  KEY `idx_batch_current_provider` (`current_provider_id`),
  KEY `idx_batch_runs_pdf_status` (`pdf_generation_status`),
  KEY `idx_batch_runs_pdf_timing` (`pdf_generation_started_at`,`pdf_generation_completed_at`),
  KEY `idx_batch_runs_status_created` (`status`,`created_at`),
  KEY `idx_report_type` (`report_type`),
  KEY `idx_audit_adjustments_applied` (`audit_adjustments_applied`),
  KEY `idx_audit_run_id` (`audit_run_id`),
  CONSTRAINT `fk_batch_audit_run` FOREIGN KEY (`audit_run_id`) REFERENCES `quarterly_audit_runs` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `batch_pdf_files`
--

DROP TABLE IF EXISTS `batch_pdf_files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `batch_pdf_files` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `batch_id` varchar(36) NOT NULL,
  `provider_id` int(11) DEFAULT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_size` bigint(20) DEFAULT NULL,
  `file_type` enum('individual','summary','archive') NOT NULL DEFAULT 'individual',
  `employment_category` enum('Employees','Independent_Contractors','Hygienists') DEFAULT NULL,
  `provider_type` varchar(50) DEFAULT NULL,
  `pay_period_start` date NOT NULL,
  `pay_period_end` date NOT NULL,
  `generation_status` enum('pending','processing','completed','failed') NOT NULL DEFAULT 'pending',
  `generation_started_at` timestamp NULL DEFAULT NULL,
  `generation_completed_at` timestamp NULL DEFAULT NULL,
  `generation_duration_ms` int(11) DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `error_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`error_details`)),
  `file_hash` varchar(64) DEFAULT NULL,
  `is_archived` tinyint(1) DEFAULT 0,
  `archive_path` varchar(500) DEFAULT NULL,
  `template_version` varchar(20) DEFAULT NULL,
  `generation_metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`generation_metadata`)),
  `is_downloadable` tinyint(1) DEFAULT 1,
  `download_count` int(11) DEFAULT 0,
  `last_downloaded_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_batch_pdf_files_batch` (`batch_id`),
  KEY `idx_batch_pdf_files_provider` (`provider_id`),
  KEY `idx_batch_pdf_files_category` (`employment_category`),
  KEY `idx_batch_pdf_files_status` (`generation_status`),
  KEY `idx_batch_pdf_files_pay_period` (`pay_period_start`,`pay_period_end`),
  KEY `idx_batch_pdf_files_file_type` (`file_type`),
  KEY `idx_batch_pdf_files_provider_type` (`provider_type`)
) ENGINE=InnoDB AUTO_INCREMENT=402 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `compensation_rates`
--

DROP TABLE IF EXISTS `compensation_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `compensation_rates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `provider_id` int(11) NOT NULL,
  `rate_type` enum('compensation','daily_guarantee') NOT NULL DEFAULT 'compensation',
  `procedure_category` enum('standard','hygiene','restorative','ortho') NOT NULL DEFAULT 'standard',
  `compensation_percentage` decimal(5,2) NOT NULL DEFAULT 0.00 COMMENT 'Percentage rate (e.g., 55.00 for 55%)',
  `daily_guarantee_rate` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Daily guarantee amount (e.g., 800.00 for $800/day)',
  `effective_date` date NOT NULL,
  `notes` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_provider_rates` (`provider_id`,`effective_date`,`is_active`),
  KEY `idx_rate_type` (`rate_type`,`procedure_category`),
  KEY `idx_active_rates` (`is_active`,`effective_date`),
  CONSTRAINT `compensation_rates_ibfk_1` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Multi-category compensation rates for providers';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `database_connections`
--

DROP TABLE IF EXISTS `database_connections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `database_connections` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `connection_label` varchar(100) NOT NULL,
  `connection_type` enum('database','api') NOT NULL DEFAULT 'database',
  `system_type` varchar(100) NOT NULL,
  `access_level` enum('read-only','read-write') DEFAULT 'read-only',
  `is_default` tinyint(1) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 0,
  `description` text DEFAULT NULL,
  `db_host` varchar(255) DEFAULT NULL,
  `db_port` int(11) DEFAULT 3306,
  `db_name` varchar(100) DEFAULT NULL,
  `db_user` varchar(100) DEFAULT NULL,
  `db_password_encrypted` text DEFAULT NULL,
  `api_base_url` varchar(255) DEFAULT NULL,
  `api_auth_type` enum('odfhir','bearer-token','api-key','basic-auth','oauth','custom-header') DEFAULT NULL,
  `api_token_encrypted` text DEFAULT NULL,
  `api_username` varchar(100) DEFAULT NULL,
  `api_password_encrypted` text DEFAULT NULL,
  `api_custom_auth_value_encrypted` text DEFAULT NULL,
  `oauth_client_id` varchar(255) DEFAULT NULL,
  `oauth_client_secret_encrypted` text DEFAULT NULL,
  `oauth_refresh_token_encrypted` text DEFAULT NULL,
  `oauth_redirect_uri` varchar(255) DEFAULT NULL,
  `api_test_endpoint` varchar(255) DEFAULT '/ping',
  `api_test_method` enum('GET','POST','PUT','DELETE') DEFAULT 'GET',
  `api_test_expected_response` text DEFAULT NULL,
  `configuration_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`configuration_json`)),
  `test_status` enum('pending','success','failed') DEFAULT 'pending',
  `test_results` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`test_results`)),
  `last_tested_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_connection_label` (`connection_label`),
  KEY `idx_system_type` (`system_type`),
  KEY `idx_connection_type` (`connection_type`),
  KEY `idx_active_connections` (`is_active`),
  KEY `idx_test_status` (`test_status`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `doctor_days_worked`
--

DROP TABLE IF EXISTS `doctor_days_worked`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `doctor_days_worked` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `provider_id` int(11) NOT NULL,
  `pay_period_start` date NOT NULL COMMENT 'Pay period start date (1st or 16th of month)',
  `pay_period_end` date NOT NULL COMMENT 'Pay period end date (15th or last day of month)',
  `days_worked` int(11) NOT NULL DEFAULT 0 COMMENT 'Number of days worked in this pay period',
  `notes` text DEFAULT NULL COMMENT 'Additional notes about this pay period',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_provider_pay_period` (`provider_id`,`pay_period_start`,`pay_period_end`),
  KEY `idx_provider_periods` (`provider_id`,`pay_period_start`,`pay_period_end`),
  KEY `idx_pay_period_range` (`pay_period_start`,`pay_period_end`),
  KEY `idx_doctor_days_provider_period` (`provider_id`,`pay_period_start`),
  CONSTRAINT `doctor_days_worked_ibfk_1` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_days_worked_positive` CHECK (`days_worked` >= 0),
  CONSTRAINT `chk_days_worked_reasonable` CHECK (`days_worked` <= 31),
  CONSTRAINT `chk_pay_period_order` CHECK (`pay_period_start` <= `pay_period_end`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Simple tracking of doctor days worked per pay period - calculations done on-demand';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `grooming_audit_log`
--

DROP TABLE IF EXISTS `grooming_audit_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `grooming_audit_log` (
  `audit_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `recommendation_id` bigint(20) NOT NULL COMMENT 'Reference to grooming_recommendations',
  `AptNum` bigint(20) NOT NULL COMMENT 'Open Dental appointment ID',
  `PatNum` bigint(20) NOT NULL COMMENT 'Open Dental patient ID',
  `action_type` varchar(20) NOT NULL COMMENT 'ADD, REMOVE procedure action',
  `proc_code` varchar(10) NOT NULL COMMENT 'Procedure code (e.g., D0274, D1110)',
  `executed_at` datetime NOT NULL COMMENT 'When action was executed',
  `executed_by` int(11) NOT NULL COMMENT 'User ID who executed action',
  `success` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Whether API call succeeded',
  `api_response` text DEFAULT NULL COMMENT 'Open Dental API response (for debugging)',
  `error_message` varchar(500) DEFAULT NULL COMMENT 'Error details if failed',
  `retry_count` int(11) NOT NULL DEFAULT 0 COMMENT 'Number of retry attempts',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`audit_id`),
  KEY `idx_grooming_audit_rec` (`recommendation_id`),
  KEY `idx_grooming_audit_aptnum` (`AptNum`),
  KEY `idx_grooming_audit_patnum` (`PatNum`),
  KEY `idx_grooming_audit_executed` (`executed_at`),
  KEY `idx_grooming_audit_executed_by` (`executed_by`),
  KEY `idx_grooming_audit_success` (`success`),
  KEY `idx_grooming_audit_failures` (`success`,`retry_count`),
  CONSTRAINT `grooming_audit_log_ibfk_1` FOREIGN KEY (`recommendation_id`) REFERENCES `grooming_recommendations` (`recommendation_id`) ON DELETE CASCADE,
  CONSTRAINT `grooming_audit_log_ibfk_2` FOREIGN KEY (`executed_by`) REFERENCES `users` (`id`),
  CONSTRAINT `chk_grooming_audit_action_type` CHECK (`action_type` in ('ADD','REMOVE'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Audit trail for grooming actions taken via Open Dental API';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `grooming_feedback`
--

DROP TABLE IF EXISTS `grooming_feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `grooming_feedback` (
  `feedback_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `recommendation_id` bigint(20) DEFAULT NULL COMMENT 'Reference to grooming_recommendations at time of report',
  `AptNum` bigint(20) NOT NULL COMMENT 'Open Dental appointment ID',
  `PatNum` bigint(20) NOT NULL COMMENT 'Open Dental patient ID',
  `target_date` date NOT NULL COMMENT 'Target date of the recommendation',
  `patient_name` varchar(100) NOT NULL COMMENT 'Patient name for quick reference',
  `issue_type` varchar(50) NOT NULL COMMENT 'Category: pp_wrong, xray_wrong, insurance_wrong, etc.',
  `affected_checks` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'JSON array of affected check types' CHECK (json_valid(`affected_checks`)),
  `priority` varchar(20) NOT NULL DEFAULT 'medium' COMMENT 'low, medium, high',
  `user_notes` text NOT NULL COMMENT 'Description of what was wrong',
  `user_fix_notes` text DEFAULT NULL COMMENT 'How the user fixed the issue in Open Dental',
  `recommendation_snapshot` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT 'Complete recommendation data at time of report' CHECK (json_valid(`recommendation_snapshot`)),
  `status` varchar(20) NOT NULL DEFAULT 'new' COMMENT 'new, reviewed, resolved',
  `admin_notes` text DEFAULT NULL COMMENT 'Notes from admin during review',
  `resolution_type` varchar(50) DEFAULT NULL COMMENT 'bug_fixed, data_issue, user_error, wont_fix, duplicate',
  `submitted_by` int(11) NOT NULL COMMENT 'User ID who submitted the feedback',
  `reviewed_by` int(11) DEFAULT NULL COMMENT 'User ID who reviewed the feedback',
  `resolved_by` int(11) DEFAULT NULL COMMENT 'User ID who resolved the feedback',
  `submitted_at` datetime NOT NULL DEFAULT current_timestamp(),
  `reviewed_at` datetime DEFAULT NULL,
  `resolved_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`feedback_id`),
  KEY `fk_grooming_feedback_reviewed_by` (`reviewed_by`),
  KEY `fk_grooming_feedback_resolved_by` (`resolved_by`),
  KEY `idx_grooming_feedback_status` (`status`),
  KEY `idx_grooming_feedback_issue_type` (`issue_type`),
  KEY `idx_grooming_feedback_priority` (`priority`),
  KEY `idx_grooming_feedback_aptnum` (`AptNum`),
  KEY `idx_grooming_feedback_target_date` (`target_date`),
  KEY `idx_grooming_feedback_submitted_by` (`submitted_by`),
  KEY `idx_grooming_feedback_submitted_at` (`submitted_at`),
  CONSTRAINT `fk_grooming_feedback_resolved_by` FOREIGN KEY (`resolved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_grooming_feedback_reviewed_by` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_grooming_feedback_submitted_by` FOREIGN KEY (`submitted_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User feedback and issue reports for grooming recommendations';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `grooming_membership_verifications`
--

DROP TABLE IF EXISTS `grooming_membership_verifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `grooming_membership_verifications` (
  `verification_id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'Unique verification ID',
  `PatNum` bigint(20) NOT NULL COMMENT 'Open Dental patient ID',
  `DiscountPlanNum` bigint(20) NOT NULL COMMENT 'Open Dental discount plan ID',
  `verified_at` datetime NOT NULL COMMENT 'When the verification was performed',
  `verified_by` varchar(50) NOT NULL COMMENT 'Username or user ID who verified',
  `status` varchar(20) NOT NULL COMMENT 'Verification status: Active, Inactive, Expired',
  `notes` varchar(255) DEFAULT NULL COMMENT 'Optional notes about the verification',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Record creation timestamp',
  PRIMARY KEY (`verification_id`),
  KEY `idx_membership_ver_patnum` (`PatNum`),
  KEY `idx_membership_ver_verified_at` (`verified_at`),
  KEY `idx_membership_ver_discountplan` (`DiscountPlanNum`),
  KEY `idx_membership_ver_patnum_plan_date` (`PatNum`,`DiscountPlanNum`,`verified_at`),
  CONSTRAINT `chk_membership_ver_status` CHECK (`status` in ('Active','Inactive','Expired'))
) ENGINE=InnoDB AUTO_INCREMENT=410 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tracks membership verification status for grooming workflow';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `grooming_recommendations`
--

DROP TABLE IF EXISTS `grooming_recommendations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `grooming_recommendations` (
  `recommendation_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `run_id` bigint(20) DEFAULT NULL COMMENT 'DEPRECATED: Original run_id, use last_run_id instead',
  `AptNum` bigint(20) NOT NULL COMMENT 'Open Dental appointment ID',
  `PatNum` bigint(20) NOT NULL COMMENT 'Open Dental patient ID',
  `patient_name` varchar(100) NOT NULL COMMENT 'Cached for display (no PHI lookup needed)',
  `apt_datetime` datetime NOT NULL COMMENT 'Appointment date and time',
  `apt_DateTStamp` datetime NOT NULL COMMENT 'Open Dental last modified timestamp',
  `xray_status` varchar(255) DEFAULT NULL,
  `xray_recommendation` varchar(200) DEFAULT NULL COMMENT 'X-ray recommendation text',
  `probing_status` varchar(255) DEFAULT NULL,
  `probing_recommendation` varchar(200) DEFAULT NULL COMMENT 'Probing recommendation text',
  `pano_status` varchar(255) DEFAULT NULL,
  `pano_recommendation` varchar(200) DEFAULT NULL COMMENT 'Pano recommendation text',
  `insurance_status` varchar(100) DEFAULT NULL COMMENT 'VERIFIED THIS MONTH, NEEDS VERIFICATION, NEVER VERIFIED',
  `insurance_recommendation` varchar(200) DEFAULT NULL COMMENT 'Insurance verification recommendation',
  `balance_status` varchar(200) DEFAULT NULL COMMENT 'Family balance and claims status',
  `balance_recommendation` varchar(200) DEFAULT NULL COMMENT 'Balance/claims recommendation',
  `credit_status` varchar(200) DEFAULT NULL COMMENT 'Credit balance status with TX analysis',
  `credit_recommendation` varchar(200) DEFAULT NULL COMMENT 'Credit balance recommendation',
  `fluoride_status` varchar(100) DEFAULT NULL COMMENT 'Fluoride eligibility status',
  `fluoride_recommendation` varchar(200) DEFAULT NULL COMMENT 'Fluoride recommendation',
  `age_code_status` varchar(100) DEFAULT NULL COMMENT 'D1110/D1120 verification status',
  `age_code_recommendation` varchar(200) DEFAULT NULL COMMENT 'Age code recommendation',
  `exam_status` varchar(255) DEFAULT NULL,
  `exam_recommendation` varchar(200) DEFAULT NULL COMMENT 'Exam recommendation text',
  `scheduled_exam_codes` varchar(100) DEFAULT NULL COMMENT 'Scheduled exam codes (e.g., D0120)',
  `scheduled_exam_procnums` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Array of ProcNums for scheduled exam' CHECK (json_valid(`scheduled_exam_procnums`)),
  `scheduled_bwx_codes` varchar(100) DEFAULT NULL COMMENT 'Scheduled BWX procedure codes (e.g., D0274)',
  `scheduled_bwx_procnums` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Array of ProcNums for scheduled BWX' CHECK (json_valid(`scheduled_bwx_procnums`)),
  `scheduled_probing_codes` varchar(100) DEFAULT NULL COMMENT 'Scheduled probing procedure codes',
  `scheduled_probing_procnums` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Array of ProcNums for scheduled probing' CHECK (json_valid(`scheduled_probing_procnums`)),
  `scheduled_pano_codes` varchar(100) DEFAULT NULL COMMENT 'Scheduled pano procedure codes',
  `scheduled_pano_procnums` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Array of ProcNums for scheduled pano' CHECK (json_valid(`scheduled_pano_procnums`)),
  `has_flags` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Quick filter - any issues found?',
  `is_new` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'New/changed since last run',
  `is_new_patient` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'No procedure history - needs full workup',
  `is_lapsed_patient` tinyint(1) DEFAULT 0 COMMENT 'Lapsed patients (3+ years since hygiene)',
  `action_status` varchar(20) NOT NULL DEFAULT 'pending' COMMENT 'pending, approved, executed, skipped',
  `reviewed_by` int(11) DEFAULT NULL COMMENT 'User ID who reviewed (Phase 2+)',
  `reviewed_at` datetime DEFAULT NULL COMMENT 'When reviewed (Phase 2+)',
  `patient_portion` decimal(10,2) DEFAULT NULL COMMENT 'Estimated patient portion for hygiene procedure',
  `patient_portion_note` varchar(255) DEFAULT NULL COMMENT 'PP note: (cash), (ded not met), (discount plan), or OD estimate notes',
  `annual_max_remaining` decimal(10,2) DEFAULT NULL COMMENT 'Remaining annual insurance maximum',
  `annual_max_status` varchar(20) DEFAULT NULL COMMENT 'Annual max status: OK, WARNING, CRITICAL, NO_MAX, N/A',
  `waiting_periods` text DEFAULT NULL COMMENT 'JSON array of active waiting periods',
  `membership_status` varchar(20) DEFAULT NULL COMMENT 'Membership verification status',
  `generated_note` text DEFAULT NULL COMMENT 'Generated appointment note text',
  `od_appointment_note` text DEFAULT NULL COMMENT 'Current Open Dental appointment note from appointment.Note',
  `target_date` date NOT NULL COMMENT 'Target date for appointment analysis',
  `last_run_id` bigint(20) DEFAULT NULL COMMENT 'Most recent run that touched this record',
  `is_delta_add` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'True if first added during a delta run',
  `groomed_at` datetime DEFAULT NULL COMMENT 'When marked complete by front desk',
  `groomed_by` int(11) DEFAULT NULL COMMENT 'User ID who marked complete',
  `note_written` tinyint(1) DEFAULT 0 COMMENT 'Whether note was written to OD',
  `note_written_at` datetime DEFAULT NULL COMMENT 'When note was written to OD',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `pp_calculation_detail` text DEFAULT NULL COMMENT 'JSON breakdown of PP calculation for debugging',
  `standard_codes_status` varchar(50) DEFAULT NULL COMMENT 'Standard codes status: complete, needs_add, or NULL',
  `standard_codes_recommendation` varchar(200) DEFAULT NULL COMMENT 'Standard codes recommendation: ADD 1003, ADD D1330, etc.',
  `hygiene_status` varchar(50) DEFAULT NULL COMMENT 'Hygiene code status: correct, needs_change, or NULL',
  `hygiene_recommendation` varchar(200) DEFAULT NULL COMMENT 'Hygiene recommendation: CHANGE to D4910 (last was PMT)',
  `scheduled_hygiene_codes` varchar(100) DEFAULT NULL COMMENT 'Comma-separated scheduled hygiene codes (D1110, D1120, D4910)',
  `scheduled_hygiene_procnums` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'JSON array of scheduled hygiene ProcNums for Codes panel actions' CHECK (json_valid(`scheduled_hygiene_procnums`)),
  `last_hygiene_code` varchar(10) DEFAULT NULL COMMENT 'Last completed hygiene code: D1110, D1120, D4910',
  `scheduled_hygiene_code` varchar(10) DEFAULT NULL COMMENT 'Currently scheduled hygiene code on this apt',
  `duplicate_tp_status` varchar(50) DEFAULT NULL COMMENT 'Duplicate TP status: needs_cleanup, clean, partial, or NULL',
  `duplicate_tp_recommendation` text DEFAULT NULL COMMENT 'Duplicate TP recommendation message(s)',
  `duplicate_tp_procnums` text DEFAULT NULL COMMENT 'Comma-separated ProcNums flagged for removal',
  PRIMARY KEY (`recommendation_id`),
  UNIQUE KEY `uq_grooming_rec_date_apt` (`target_date`,`AptNum`),
  KEY `idx_grooming_rec_run` (`run_id`),
  KEY `idx_grooming_rec_aptnum` (`AptNum`),
  KEY `idx_grooming_rec_patnum` (`PatNum`),
  KEY `idx_grooming_rec_has_flags` (`has_flags`),
  KEY `idx_grooming_rec_apt_datetime` (`apt_datetime`),
  KEY `idx_grooming_rec_is_new` (`is_new`),
  KEY `idx_grooming_rec_is_new_patient` (`is_new_patient`),
  KEY `idx_grooming_rec_run_flags` (`run_id`,`has_flags`),
  KEY `idx_grooming_rec_run_apt` (`run_id`,`apt_datetime`),
  KEY `idx_grooming_rec_target_date` (`target_date`),
  KEY `idx_grooming_rec_membership_status` (`membership_status`),
  KEY `idx_grooming_recommendations_lapsed` (`is_lapsed_patient`),
  KEY `idx_grooming_rec_groomed` (`target_date`,`groomed_at`),
  KEY `fk_grooming_rec_last_run` (`last_run_id`),
  KEY `fk_grooming_rec_groomed_by` (`groomed_by`),
  KEY `idx_grooming_rec_standard_codes` (`standard_codes_status`),
  KEY `idx_grooming_rec_hygiene` (`hygiene_status`),
  KEY `idx_grooming_rec_duplicate_tp` (`duplicate_tp_status`),
  CONSTRAINT `fk_grooming_rec_groomed_by` FOREIGN KEY (`groomed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_grooming_rec_last_run` FOREIGN KEY (`last_run_id`) REFERENCES `grooming_runs` (`run_id`) ON DELETE SET NULL,
  CONSTRAINT `chk_grooming_rec_action_status` CHECK (`action_status` in ('pending','approved','executed','skipped'))
) ENGINE=InnoDB AUTO_INCREMENT=36625 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Individual appointment recommendations from grooming analysis runs';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `grooming_runs`
--

DROP TABLE IF EXISTS `grooming_runs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `grooming_runs` (
  `run_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `target_date` date NOT NULL COMMENT 'Target date for analysis (start date for range)',
  `end_date` date DEFAULT NULL COMMENT 'NULL for single date, set for date range',
  `start_time` datetime NOT NULL COMMENT 'When the run started',
  `end_time` datetime DEFAULT NULL COMMENT 'When the run completed (NULL if running)',
  `last_checked_timestamp` datetime DEFAULT NULL COMMENT 'For delta logic - SecDateTEdit cutoff from last run',
  `total_appointments` int(11) NOT NULL DEFAULT 0 COMMENT 'Total appointments processed',
  `new_appointments` int(11) NOT NULL DEFAULT 0 COMMENT 'New/changed appointments since last run',
  `total_flags` int(11) NOT NULL DEFAULT 0 COMMENT 'Total recommendations/flags found',
  `status` varchar(20) NOT NULL DEFAULT 'running' COMMENT 'running, complete, failed',
  `triggered_by` int(11) NOT NULL COMMENT 'User ID who triggered the run',
  `is_delta_run` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'Whether this was a delta run (only new/changed)',
  `error_message` text DEFAULT NULL COMMENT 'Error details if run failed',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `viewed_at` datetime DEFAULT NULL COMMENT 'Timestamp when run was first viewed by a user',
  `viewed_by` int(11) DEFAULT NULL COMMENT 'User ID who first viewed the run',
  PRIMARY KEY (`run_id`),
  KEY `idx_grooming_runs_target_date` (`target_date`),
  KEY `idx_grooming_runs_status` (`status`),
  KEY `idx_grooming_runs_created` (`created_at`),
  KEY `idx_grooming_runs_triggered_by` (`triggered_by`),
  KEY `idx_grooming_runs_date_range` (`target_date`,`end_date`),
  KEY `fk_grooming_runs_viewed_by` (`viewed_by`),
  CONSTRAINT `fk_grooming_runs_viewed_by` FOREIGN KEY (`viewed_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `grooming_runs_ibfk_1` FOREIGN KEY (`triggered_by`) REFERENCES `users` (`id`),
  CONSTRAINT `chk_grooming_runs_status` CHECK (`status` in ('running','complete','failed'))
) ENGINE=InnoDB AUTO_INCREMENT=1062 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tracks each grooming analysis run for hygiene appointment checks';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `grooming_settings`
--

DROP TABLE IF EXISTS `grooming_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `grooming_settings` (
  `setting_key` varchar(50) NOT NULL COMMENT 'Unique key for the setting',
  `setting_value` varchar(255) NOT NULL COMMENT 'Value of the setting',
  `setting_type` varchar(20) NOT NULL COMMENT 'Type: number, string, boolean',
  `category` varchar(50) NOT NULL COMMENT 'Category: frequencies, thresholds, age_rules, procedure_codes, coverage_categories',
  `description` varchar(255) DEFAULT NULL COMMENT 'Human-readable description of the setting',
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Last update timestamp',
  PRIMARY KEY (`setting_key`),
  KEY `idx_grooming_settings_category` (`category`),
  CONSTRAINT `chk_grooming_settings_type` CHECK (`setting_type` in ('number','string','boolean'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Configurable settings for the grooming module';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hygienist_bonus_rates`
--

DROP TABLE IF EXISTS `hygienist_bonus_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `hygienist_bonus_rates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bonus_type` varchar(50) NOT NULL COMMENT 'Type of bonus (fluoride, io_rinse, spry_spray, mi_paste, clinpro, night_guard, laser, patient_bonus)',
  `procedure_code` varchar(20) DEFAULT NULL COMMENT 'Open Dental procedure code (D1206, D0010, etc.)',
  `bonus_name` varchar(100) NOT NULL COMMENT 'Display name for the bonus type',
  `bonus_rate` decimal(10,2) NOT NULL DEFAULT 0.00 COMMENT 'Dollar amount per procedure',
  `is_active` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Whether this bonus type is currently active',
  `calculation_method` enum('per_procedure','per_patient','flat_rate') NOT NULL DEFAULT 'per_procedure' COMMENT 'How the bonus is calculated',
  `description` text DEFAULT NULL COMMENT 'Additional details about this bonus type',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `excluded_carriers` text DEFAULT NULL COMMENT 'Comma-separated list of insurance carrier patterns to exclude from bonus',
  PRIMARY KEY (`id`),
  UNIQUE KEY `bonus_type` (`bonus_type`),
  KEY `is_active` (`is_active`),
  KEY `procedure_code` (`procedure_code`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Configurable bonus rates for hygienist compensation';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hygienist_extra_patients`
--

DROP TABLE IF EXISTS `hygienist_extra_patients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `hygienist_extra_patients` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `provider_id` int(11) NOT NULL,
  `work_date` date NOT NULL,
  `extra_patient_count` int(11) NOT NULL,
  `rate_per_patient` decimal(10,2) NOT NULL,
  `bonus_amount` decimal(10,2) GENERATED ALWAYS AS (`extra_patient_count` * `rate_per_patient`) STORED,
  `pay_period_start` date NOT NULL,
  `pay_period_end` date NOT NULL,
  `notes` text DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_active` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Soft delete flag: 1 = active, 0 = deleted',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_provider_date` (`provider_id`,`work_date`),
  KEY `idx_provider_date` (`provider_id`,`work_date`),
  KEY `idx_provider_period` (`provider_id`,`pay_period_start`,`pay_period_end`),
  KEY `idx_period` (`pay_period_start`,`pay_period_end`),
  KEY `idx_approved` (`approved_by`,`approved_at`),
  KEY `idx_hygienist_extra_patients_active` (`is_active`),
  KEY `idx_hygienist_extra_patients_period_active` (`pay_period_start`,`pay_period_end`,`is_active`),
  KEY `idx_hygienist_extra_provider_date` (`provider_id`,`work_date`),
  CONSTRAINT `chk_extra_patients` CHECK (`extra_patient_count` > 0 and `extra_patient_count` <= 8),
  CONSTRAINT `chk_rate` CHECK (`rate_per_patient` > 0),
  CONSTRAINT `chk_work_date_in_period` CHECK (`work_date` >= `pay_period_start` and `work_date` <= `pay_period_end`)
) ENGINE=InnoDB AUTO_INCREMENT=233 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `login_attempts`
--

DROP TABLE IF EXISTS `login_attempts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `login_attempts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL COMMENT 'Username attempted (may not exist in users table)',
  `ip_address` varchar(45) NOT NULL COMMENT 'Client IP address',
  `success` tinyint(1) NOT NULL COMMENT 'Whether login was successful',
  `failure_reason` varchar(100) DEFAULT NULL COMMENT 'Reason for login failure (invalid_username, invalid_password, account_locked, etc.)',
  `user_agent` text DEFAULT NULL COMMENT 'Client user agent string',
  `session_id` varchar(128) DEFAULT NULL COMMENT 'Session ID if successful',
  `timestamp` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_username_attempts` (`username`,`timestamp`),
  KEY `idx_ip_attempts` (`ip_address`,`timestamp`),
  KEY `idx_failed_attempts` (`success`,`timestamp`),
  KEY `idx_cleanup_attempts` (`timestamp`),
  KEY `idx_security_monitoring` (`ip_address`,`success`,`timestamp`),
  KEY `idx_login_attempts_username_timestamp` (`username`,`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Track login attempts for security monitoring and rate limiting';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `migration_history`
--

DROP TABLE IF EXISTS `migration_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `migration_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `migration_name` varchar(255) NOT NULL,
  `executed_at` timestamp NULL DEFAULT current_timestamp(),
  `execution_time_ms` int(11) DEFAULT NULL,
  `success` tinyint(1) DEFAULT 1,
  `error_message` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_migration_name` (`migration_name`),
  KEY `idx_executed_at` (`executed_at`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `migration_log`
--

DROP TABLE IF EXISTS `migration_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `migration_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `migration_name` varchar(255) NOT NULL,
  `executed_at` timestamp NULL DEFAULT current_timestamp(),
  `description` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `migration_name` (`migration_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `oral_surgeon_settings`
--

DROP TABLE IF EXISTS `oral_surgeon_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `oral_surgeon_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `setting_type` enum('flat_rate','production_exclusion','general_setting') NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text NOT NULL,
  `display_name` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_setting` (`setting_type`,`setting_key`),
  KEY `idx_setting_type` (`setting_type`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_setting_key` (`setting_key`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ortho_lab_fees`
--

DROP TABLE IF EXISTS `ortho_lab_fees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ortho_lab_fees` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `procedure_name` varchar(255) NOT NULL,
  `procedure_code` varchar(50) NOT NULL,
  `fee_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `effective_date` date NOT NULL DEFAULT curdate(),
  `end_date` date DEFAULT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_procedure_code` (`procedure_code`),
  KEY `idx_active_fees` (`is_active`),
  KEY `idx_procedure_name` (`procedure_name`),
  KEY `idx_ortho_fees_temporal` (`procedure_code`,`effective_date`,`end_date`),
  KEY `idx_ortho_fees_active` (`procedure_code`,`end_date`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Ortho lab fees with temporal tracking. NULL end_date means currently active. When querying historical data, use the fee where service_date BETWEEN effective_date AND COALESCE(end_date, service_date)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `password_resets`
--

DROP TABLE IF EXISTS `password_resets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_resets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `reset_by_user_id` int(11) DEFAULT NULL,
  `reset_type` enum('ADMIN_RESET','USER_REQUEST','SYSTEM_FORCED') NOT NULL DEFAULT 'USER_REQUEST',
  `reason` text DEFAULT NULL,
  `temporary_password_set` tinyint(1) NOT NULL DEFAULT 0,
  `force_change_required` tinyint(1) NOT NULL DEFAULT 1,
  `token` varchar(255) DEFAULT NULL,
  `token_expires_at` datetime DEFAULT NULL,
  `used_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_password_resets_reset_by` (`reset_by_user_id`),
  KEY `idx_password_resets_user_id` (`user_id`),
  KEY `idx_password_resets_created_at` (`created_at`),
  KEY `idx_password_resets_token` (`token`(250)),
  KEY `idx_password_resets_token_expires` (`token_expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payroll_calculations`
--

DROP TABLE IF EXISTS `payroll_calculations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payroll_calculations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `provider_id` int(11) NOT NULL,
  `calculation_date` datetime DEFAULT current_timestamp(),
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `gross_production` decimal(10,2) DEFAULT 0.00,
  `net_production` decimal(10,2) DEFAULT 0.00,
  `adjustments_total` decimal(10,2) DEFAULT 0.00,
  `writeoffs_total` decimal(10,2) DEFAULT 0.00,
  `final_compensation` decimal(10,2) NOT NULL,
  `total_payment` decimal(10,2) NOT NULL,
  `calculation_method` varchar(50) DEFAULT NULL,
  `calculation_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`calculation_data`)),
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_calc_provider` (`provider_id`),
  KEY `idx_calc_period` (`start_date`,`end_date`),
  KEY `idx_calc_created` (`created_at`),
  CONSTRAINT `payroll_calculations_ibfk_1` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=329 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payroll_reports`
--

DROP TABLE IF EXISTS `payroll_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payroll_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `provider_id` int(11) NOT NULL,
  `period_start_date` date NOT NULL,
  `period_end_date` date NOT NULL,
  `gross_production` decimal(10,2) DEFAULT 0.00,
  `adjustments` decimal(10,2) DEFAULT 0.00,
  `writeoffs` decimal(10,2) DEFAULT 0.00,
  `net_production` decimal(10,2) DEFAULT 0.00,
  `production_pay` decimal(10,2) NOT NULL,
  `daily_guarantee` decimal(10,2) NOT NULL,
  `pto_pay` decimal(10,2) DEFAULT 0.00,
  `total_pay` decimal(10,2) NOT NULL,
  `report_status` enum('draft','finalized','approved','paid') DEFAULT 'draft',
  `notes` text DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `provider_id` (`provider_id`),
  KEY `idx_report_period` (`period_start_date`,`period_end_date`),
  KEY `idx_report_status` (`report_status`),
  CONSTRAINT `payroll_reports_ibfk_1` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payroll_settings`
--

DROP TABLE IF EXISTS `payroll_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payroll_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `setting_type` enum('provider_specific','provider_type','adjustment_rule','procedure_codes') NOT NULL,
  `setting_category` varchar(50) NOT NULL COMMENT 'exclusions, bonus_rates, flat_rates, general, working_days',
  `setting_key` varchar(100) NOT NULL COMMENT 'Unique identifier for the setting',
  `provider_id` int(11) DEFAULT NULL COMMENT 'NULL for provider-type settings, specific provider ID for provider-specific settings',
  `provider_type` varchar(50) DEFAULT NULL COMMENT 'oral_surgeon, general_dentist, hygienist, endodontist - for provider_type settings',
  `setting_value` text NOT NULL COMMENT 'The actual setting value - can be JSON, number, string, boolean',
  `display_name` varchar(255) DEFAULT NULL COMMENT 'Human-readable name for UI display',
  `description` text DEFAULT NULL COMMENT 'Detailed description of what this setting controls',
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Flexible configuration data - procedure codes, conditions, etc.' CHECK (json_valid(`metadata`)),
  `effective_date` date NOT NULL DEFAULT curdate() COMMENT 'When this setting becomes active',
  `end_date` date DEFAULT NULL COMMENT 'When this setting expires - NULL means currently active',
  `is_active` tinyint(1) DEFAULT 1 COMMENT 'Quick enable/disable without changing dates',
  `created_by` int(11) DEFAULT NULL COMMENT 'User who created this setting',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_provider_settings` (`provider_id`,`setting_type`,`effective_date`),
  KEY `idx_provider_type_settings` (`provider_type`,`setting_category`,`effective_date`),
  KEY `idx_temporal_lookup` (`effective_date`,`end_date`),
  KEY `idx_active_settings` (`is_active`,`setting_type`,`setting_category`),
  KEY `idx_setting_search` (`setting_category`,`setting_key`),
  CONSTRAINT `payroll_settings_ibfk_1` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1488 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Payroll-specific settings and configurations';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `permission_conflicts`
--

DROP TABLE IF EXISTS `permission_conflicts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `permission_conflicts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_id` int(11) NOT NULL,
  `permission_name` varchar(100) NOT NULL,
  `conflict_type` enum('REDUNDANT_DIRECT','MULTIPLE_INHERITANCE','CIRCULAR_DEPENDENCY') NOT NULL,
  `conflicting_role_id` int(11) DEFAULT NULL,
  `details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`details`)),
  `severity` enum('LOW','MEDIUM','HIGH') DEFAULT 'MEDIUM',
  `status` enum('ACTIVE','RESOLVED','IGNORED') DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `resolved_at` timestamp NULL DEFAULT NULL,
  `resolved_by_user_id` int(11) DEFAULT NULL,
  `resolution_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`resolution_details`)),
  PRIMARY KEY (`id`),
  KEY `conflicting_role_id` (`conflicting_role_id`),
  KEY `resolved_by_user_id` (`resolved_by_user_id`),
  KEY `idx_role_conflict` (`role_id`),
  KEY `idx_permission_conflict` (`permission_name`),
  KEY `idx_conflict_status` (`status`),
  KEY `idx_conflict_severity` (`severity`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `permission_reviews`
--

DROP TABLE IF EXISTS `permission_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `permission_reviews` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_id` int(11) NOT NULL,
  `reviewer_user_id` int(11) NOT NULL,
  `status` enum('IN_PROGRESS','COMPLETED','CANCELLED') DEFAULT 'IN_PROGRESS',
  `started_at` timestamp NULL DEFAULT current_timestamp(),
  `completed_at` timestamp NULL DEFAULT NULL,
  `findings` text DEFAULT NULL,
  `recommendations` text DEFAULT NULL,
  `approved_permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`approved_permissions`)),
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_role_review` (`role_id`),
  KEY `idx_reviewer` (`reviewer_user_id`),
  KEY `idx_review_status` (`status`),
  KEY `idx_started_at` (`started_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `permission_name` varchar(100) NOT NULL COMMENT 'Permission identifier (e.g., users.view, payroll.edit)',
  `display_name` varchar(150) NOT NULL COMMENT 'Human-readable permission name for UI',
  `description` text DEFAULT NULL COMMENT 'Permission description',
  `category` varchar(50) NOT NULL COMMENT 'Permission category for grouping (e.g., user_management, payroll)',
  `resource_type` varchar(50) DEFAULT NULL COMMENT 'Type of resource this permission applies to',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `is_active` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Whether the permission is active and should be available for assignment',
  PRIMARY KEY (`id`),
  UNIQUE KEY `permission_name` (`permission_name`),
  KEY `idx_permission_name` (`permission_name`),
  KEY `idx_category` (`category`),
  KEY `idx_resource_type` (`resource_type`),
  KEY `idx_category_resource` (`category`,`resource_type`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='System permissions for granular access control';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `phi_access_log`
--

DROP TABLE IF EXISTS `phi_access_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `phi_access_log` (
  `log_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `timestamp` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'When the action occurred',
  `username` varchar(50) NOT NULL COMMENT 'App username who triggered the action (e.g., mdaley)',
  `user_id` int(11) DEFAULT NULL COMMENT 'FK to users table (NULL if user deleted)',
  `action_type` varchar(50) NOT NULL COMMENT 'Type of action: procedure_add, procedure_delete, appointment_note_write, popup_create',
  `PatNum` bigint(20) DEFAULT NULL COMMENT 'Open Dental patient number affected (NULL for non-patient operations)',
  `description` varchar(500) NOT NULL COMMENT 'Human-readable description with entity context (AptNum, ProcNums, etc.)',
  `success` tinyint(1) NOT NULL DEFAULT 1 COMMENT 'Whether the operation succeeded',
  `error_message` varchar(255) DEFAULT NULL COMMENT 'Error message if operation failed',
  `ip_address` varchar(45) DEFAULT NULL COMMENT 'IP address of the request origin',
  `created_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'Record creation timestamp',
  PRIMARY KEY (`log_id`),
  KEY `idx_phi_log_timestamp` (`timestamp`),
  KEY `idx_phi_log_username` (`username`),
  KEY `idx_phi_log_patnum` (`PatNum`),
  KEY `idx_phi_log_action_type` (`action_type`),
  KEY `idx_phi_log_success` (`success`),
  KEY `idx_phi_log_patnum_timestamp` (`PatNum`,`timestamp`),
  KEY `idx_phi_log_username_timestamp` (`username`,`timestamp`)
) ENGINE=InnoDB AUTO_INCREMENT=13790 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='HIPAA audit trail for PHI access via API operations - 6 year retention required';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `provider_additions`
--

DROP TABLE IF EXISTS `provider_additions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `provider_additions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `provider_id` int(11) NOT NULL,
  `provider_type` varchar(50) DEFAULT 'oral_surgeon',
  `date` date NOT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `note` text DEFAULT NULL,
  `category` varchar(50) DEFAULT 'manual_addition',
  `reference_id` varchar(100) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `idx_provider_date` (`provider_id`,`date`),
  KEY `idx_provider_type_date` (`provider_type`,`date`),
  KEY `idx_date_range` (`date`)
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `provider_adjustment_settings`
--

DROP TABLE IF EXISTS `provider_adjustment_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `provider_adjustment_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `provider_type` enum('endodontist','general_dentist','oral_surgeon','hygienist') NOT NULL,
  `procedure_category` varchar(50) NOT NULL DEFAULT 'all',
  `adjustment_type` varchar(100) DEFAULT NULL,
  `adjustment_category` varchar(50) DEFAULT NULL,
  `adjustment_type_id` int(11) NOT NULL,
  `adjustment_name` varchar(100) DEFAULT NULL,
  `is_included` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `procedure_codes` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'JSON array of procedure codes for this provider type and category' CHECK (json_valid(`procedure_codes`)),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_provider_category_adjustment` (`provider_type`,`procedure_category`,`adjustment_type_id`),
  KEY `idx_provider_type_adj` (`provider_type`),
  KEY `idx_adjustment_type` (`adjustment_type_id`),
  KEY `idx_provider_settings_covering` (`provider_type`,`adjustment_type_id`,`is_included`,`procedure_category`,`adjustment_name`),
  KEY `idx_provider_inclusion_lookup` (`provider_type`,`is_included`,`adjustment_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2845 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `provider_time_entries`
--

DROP TABLE IF EXISTS `provider_time_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `provider_time_entries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `provider_id` int(11) NOT NULL COMMENT 'Reference to providers table',
  `entry_date` date NOT NULL COMMENT 'Individual day for this time entry',
  `pay_period_start` date NOT NULL COMMENT 'Pay period start date (1st or 16th of month)',
  `pay_period_end` date NOT NULL COMMENT 'Pay period end date (15th or last day of month)',
  `time_type` enum('base','education','sick','vacation','other') NOT NULL COMMENT 'Type of time entry',
  `hours` decimal(4,2) NOT NULL COMMENT 'Hours worked (0.25 increments, max 8.00 per day)',
  `notes` text DEFAULT NULL COMMENT 'Additional notes about this time entry',
  `created_by` int(11) DEFAULT NULL COMMENT 'User ID who created this entry',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_active` tinyint(1) DEFAULT 1 COMMENT 'Soft delete flag: 1 = active, 0 = deleted',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_provider_date_type` (`provider_id`,`entry_date`,`time_type`),
  KEY `idx_provider_period` (`provider_id`,`pay_period_start`,`pay_period_end`),
  KEY `idx_time_type` (`time_type`),
  KEY `idx_entry_date` (`entry_date`),
  KEY `idx_active_entries` (`is_active`,`entry_date`),
  KEY `idx_provider_active` (`provider_id`,`is_active`),
  CONSTRAINT `provider_time_entries_ibfk_1` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_hours_positive` CHECK (`hours` > 0),
  CONSTRAINT `chk_hours_reasonable` CHECK (`hours` <= 8),
  CONSTRAINT `chk_date_in_period` CHECK (`entry_date` between `pay_period_start` and `pay_period_end`)
) ENGINE=InnoDB AUTO_INCREMENT=680 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Unified time tracking for all provider time types with hourly precision';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `providers`
--

DROP TABLE IF EXISTS `providers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `providers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `open_dental_provnum` int(11) DEFAULT NULL,
  `provider_type` enum('endodontist','general_dentist','oral_surgeon','hygienist') NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `open_dental_provnum` (`open_dental_provnum`),
  KEY `idx_provider_type` (`provider_type`),
  KEY `idx_active_providers` (`is_active`),
  KEY `idx_open_dental_provnum` (`open_dental_provnum`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quarterly_audit_providers`
--

DROP TABLE IF EXISTS `quarterly_audit_providers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `quarterly_audit_providers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `audit_run_id` int(11) NOT NULL COMMENT 'Reference to quarterly_audit_runs table',
  `provider_id` int(11) NOT NULL COMMENT 'Reference to providers table',
  `provider_name` varchar(255) NOT NULL COMMENT 'Provider name (denormalized for reporting)',
  `provider_type` varchar(50) NOT NULL COMMENT 'Provider type (denormalized)',
  `daily_rate` decimal(10,2) DEFAULT NULL COMMENT 'Daily rate at time of audit',
  `period_1_batch_id` varchar(36) DEFAULT NULL,
  `period_1_date_range` varchar(100) DEFAULT NULL,
  `period_1_amount` decimal(10,2) DEFAULT 0.00,
  `period_2_batch_id` varchar(36) DEFAULT NULL,
  `period_2_date_range` varchar(100) DEFAULT NULL,
  `period_2_amount` decimal(10,2) DEFAULT 0.00,
  `period_3_batch_id` varchar(36) DEFAULT NULL,
  `period_3_date_range` varchar(100) DEFAULT NULL,
  `period_3_amount` decimal(10,2) DEFAULT 0.00,
  `period_4_batch_id` varchar(36) DEFAULT NULL,
  `period_4_date_range` varchar(100) DEFAULT NULL,
  `period_4_amount` decimal(10,2) DEFAULT 0.00,
  `period_5_batch_id` varchar(36) DEFAULT NULL,
  `period_5_date_range` varchar(100) DEFAULT NULL,
  `period_5_amount` decimal(10,2) DEFAULT 0.00,
  `period_6_batch_id` varchar(36) DEFAULT NULL,
  `period_6_date_range` varchar(100) DEFAULT NULL,
  `period_6_amount` decimal(10,2) DEFAULT 0.00,
  `total_paid_across_periods` decimal(10,2) DEFAULT 0.00,
  `missing_periods_count` int(11) DEFAULT 0,
  `missing_periods_warning` text DEFAULT NULL,
  `quarterly_production` decimal(10,2) DEFAULT 0.00,
  `quarterly_days_worked` int(11) DEFAULT 0,
  `quarterly_calculated_amount` decimal(10,2) DEFAULT 0.00,
  `difference` decimal(10,2) DEFAULT 0.00,
  `difference_percentage` decimal(5,2) DEFAULT 0.00,
  `pdf_file_path` varchar(500) DEFAULT NULL,
  `status` enum('pending','processing','completed','failed') DEFAULT 'pending',
  `error_message` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `hygiene_paid_amount` decimal(10,2) DEFAULT 0.00,
  `hygiene_quarterly_amount` decimal(10,2) DEFAULT 0.00,
  `hygiene_difference` decimal(10,2) DEFAULT 0.00,
  `restorative_paid_amount` decimal(10,2) DEFAULT 0.00,
  `restorative_quarterly_amount` decimal(10,2) DEFAULT 0.00,
  `restorative_difference` decimal(10,2) DEFAULT 0.00,
  `ortho_paid_amount` decimal(10,2) DEFAULT 0.00,
  `ortho_quarterly_amount` decimal(10,2) DEFAULT 0.00,
  `ortho_difference` decimal(10,2) DEFAULT 0.00,
  `production_paid_amount` decimal(10,2) DEFAULT 0.00,
  `production_quarterly_amount` decimal(10,2) DEFAULT 0.00,
  `production_difference` decimal(10,2) DEFAULT 0.00,
  `bone_graft_paid_count` int(11) DEFAULT 0,
  `bone_graft_quarterly_count` int(11) DEFAULT 0,
  `bone_graft_count_difference` int(11) DEFAULT 0,
  `bone_graft_paid_amount` decimal(10,2) DEFAULT 0.00,
  `bone_graft_quarterly_amount` decimal(10,2) DEFAULT 0.00,
  `bone_graft_difference` decimal(10,2) DEFAULT 0.00,
  `sedation_paid_count` int(11) DEFAULT 0,
  `sedation_quarterly_count` int(11) DEFAULT 0,
  `sedation_count_difference` int(11) DEFAULT 0,
  `sedation_paid_amount` decimal(10,2) DEFAULT 0.00,
  `sedation_quarterly_amount` decimal(10,2) DEFAULT 0.00,
  `sedation_difference` decimal(10,2) DEFAULT 0.00,
  `additions_paid_amount` decimal(10,2) DEFAULT 0.00,
  `additions_quarterly_amount` decimal(10,2) DEFAULT 0.00,
  `additions_difference` decimal(10,2) DEFAULT 0.00,
  `category_breakdown` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`category_breakdown`)),
  `hygiene_adjustment_amount` decimal(10,2) DEFAULT 0.00,
  `restorative_adjustment_amount` decimal(10,2) DEFAULT 0.00,
  `ortho_adjustment_amount` decimal(10,2) DEFAULT 0.00,
  `production_adjustment_amount` decimal(10,2) DEFAULT 0.00,
  `bone_graft_adjustment_amount` decimal(10,2) DEFAULT 0.00,
  `sedation_adjustment_amount` decimal(10,2) DEFAULT 0.00,
  `additions_adjustment_amount` decimal(10,2) DEFAULT 0.00,
  `total_adjustment_amount` decimal(10,2) DEFAULT 0.00,
  `hygiene_commission_rate` decimal(5,4) DEFAULT NULL,
  `restorative_commission_rate` decimal(5,4) DEFAULT NULL,
  `ortho_commission_rate` decimal(5,4) DEFAULT NULL,
  `production_commission_rate` decimal(5,4) DEFAULT NULL,
  `applied_batch_id` varchar(36) DEFAULT NULL,
  `applied_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_audit_run` (`audit_run_id`),
  KEY `idx_provider` (`provider_id`),
  KEY `idx_status` (`status`),
  KEY `idx_audit_provider` (`audit_run_id`,`provider_id`),
  KEY `idx_audit_providers_applied` (`applied_batch_id`),
  CONSTRAINT `fk_qap_audit_run` FOREIGN KEY (`audit_run_id`) REFERENCES `quarterly_audit_runs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_qap_provider` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Provider-specific quarterly audit results with 6-period breakdown';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `quarterly_audit_runs`
--

DROP TABLE IF EXISTS `quarterly_audit_runs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `quarterly_audit_runs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `quarter` tinyint(4) NOT NULL COMMENT 'Quarter number (1-4)',
  `year` int(11) NOT NULL COMMENT 'Year (e.g., 2025)',
  `start_date` date NOT NULL COMMENT 'Quarter start date (Jan 1, Apr 1, Jul 1, Oct 1)',
  `end_date` date NOT NULL COMMENT 'Quarter end date (Mar 31, Jun 30, Sep 30, Dec 31)',
  `status` enum('pending','processing','completed','failed','cancelled') NOT NULL DEFAULT 'pending' COMMENT 'Audit run status',
  `progress` int(11) DEFAULT 0 COMMENT 'Progress percentage (0-100)',
  `total_providers` int(11) DEFAULT 0 COMMENT 'Total number of providers in audit',
  `processed_providers` int(11) DEFAULT 0 COMMENT 'Number of providers processed',
  `zip_file_path` varchar(500) DEFAULT NULL COMMENT 'Path to ZIP file with all PDFs',
  `summary_pdf_path` varchar(500) DEFAULT NULL COMMENT 'Path to summary PDF file',
  `error_message` text DEFAULT NULL COMMENT 'Error message if audit failed',
  `created_by` int(11) DEFAULT NULL COMMENT 'User ID who created this audit',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_quarter_year` (`quarter`,`year`),
  KEY `idx_quarter_year` (`quarter`,`year`),
  KEY `idx_status` (`status`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_audit_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Quarterly audit runs comparing 6 pay periods against fresh quarterly calculations';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `role_hierarchy`
--

DROP TABLE IF EXISTS `role_hierarchy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_hierarchy` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `parent_role_id` int(11) NOT NULL,
  `child_role_id` int(11) NOT NULL,
  `created_by_user_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_hierarchy_relationship` (`parent_role_id`,`child_role_id`),
  KEY `idx_parent_role` (`parent_role_id`),
  KEY `idx_child_role` (`child_role_id`),
  KEY `idx_created_by` (`created_by_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `role_permission_cache`
--

DROP TABLE IF EXISTS `role_permission_cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permission_cache` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_id` int(11) NOT NULL,
  `permission_name` varchar(100) NOT NULL,
  `cached_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_role_permission_cache` (`role_id`,`permission_name`),
  KEY `idx_role_cache` (`role_id`),
  KEY `idx_permission_cache` (`permission_name`),
  KEY `idx_cached_at` (`cached_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `role_permissions`
--

DROP TABLE IF EXISTS `role_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permissions` (
  `role_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  `granted_at` timestamp NULL DEFAULT current_timestamp(),
  `granted_by_user_id` int(11) DEFAULT NULL COMMENT 'User who granted this permission',
  PRIMARY KEY (`role_id`,`permission_id`),
  KEY `idx_role_permissions` (`role_id`),
  KEY `idx_permission_roles` (`permission_id`),
  CONSTRAINT `role_permissions_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `role_permissions_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Many-to-many mapping between roles and permissions';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) NOT NULL COMMENT 'Role name identifier (e.g., admin_user, provider_user)',
  `display_name` varchar(100) NOT NULL COMMENT 'Human-readable role name for UI',
  `description` text DEFAULT NULL COMMENT 'Role description and purpose',
  `is_system_role` tinyint(1) DEFAULT 0 COMMENT 'Whether this is a system-defined role (cannot be deleted)',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `last_reviewed_at` timestamp NULL DEFAULT NULL,
  `review_frequency_days` int(11) DEFAULT 90,
  PRIMARY KEY (`id`),
  UNIQUE KEY `role_name` (`role_name`),
  KEY `idx_role_name` (`role_name`),
  KEY `idx_system_roles` (`is_system_role`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User roles for role-based authorization system';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `session_metadata`
--

DROP TABLE IF EXISTS `session_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `session_metadata` (
  `session_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`session_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `session_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `expires` int(11) unsigned NOT NULL,
  `data` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  PRIMARY KEY (`session_id`),
  KEY `idx_sessions_expires` (`expires`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_settings`
--

DROP TABLE IF EXISTS `system_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `setting_type` enum('string','number','boolean','json') DEFAULT 'string',
  `description` text DEFAULT NULL,
  `is_encrypted` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`),
  KEY `idx_setting_key` (`setting_key`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_activity`
--

DROP TABLE IF EXISTS `user_activity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_activity` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `activity_type` varchar(50) NOT NULL,
  `description` text NOT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_activity_user_id` (`user_id`),
  KEY `idx_user_activity_type` (`activity_type`),
  KEY `idx_user_activity_created_at` (`created_at`),
  KEY `idx_user_activity_user_created` (`user_id`,`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_providers`
--

DROP TABLE IF EXISTS `user_providers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_providers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT 'Reference to users table',
  `provider_id` int(11) NOT NULL COMMENT 'Reference to providers table',
  `relationship_type` enum('self','manager','assistant','admin') DEFAULT 'self' COMMENT 'Type of relationship: self (provider is user), manager (oversees provider), assistant (assists provider), admin (system admin)',
  `is_primary` tinyint(1) DEFAULT 0 COMMENT 'Whether this is the primary provider for this user',
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Specific permissions for this user-provider relationship' CHECK (json_valid(`permissions`)),
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_by_user_id` int(11) DEFAULT NULL COMMENT 'User who created this relationship',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_provider` (`user_id`,`provider_id`),
  KEY `idx_user_providers` (`user_id`),
  KEY `idx_provider_users` (`provider_id`),
  KEY `idx_relationship_type` (`relationship_type`),
  KEY `idx_primary_relationships` (`is_primary`,`user_id`),
  CONSTRAINT `user_providers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_providers_ibfk_2` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Flexible relationships between users and providers for data access control';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_roles` (
  `user_id` int(11) NOT NULL,
  `role_id` int(11) NOT NULL,
  `assigned_at` timestamp NULL DEFAULT current_timestamp(),
  `assigned_by_user_id` int(11) DEFAULT NULL COMMENT 'User who assigned this role',
  `expires_at` timestamp NULL DEFAULT NULL COMMENT 'Optional role expiration date',
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `idx_user_roles` (`user_id`),
  KEY `idx_role_users` (`role_id`),
  KEY `idx_assigned_by` (`assigned_by_user_id`),
  KEY `idx_role_expiration` (`expires_at`),
  CONSTRAINT `user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Many-to-many mapping between users and roles';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `user_sessions`
--

DROP TABLE IF EXISTS `user_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_sessions` (
  `session_id` varchar(128) NOT NULL,
  `user_id` int(11) DEFAULT NULL COMMENT 'User associated with this session (NULL for anonymous sessions)',
  `expires` bigint(20) NOT NULL COMMENT 'Session expiration timestamp in milliseconds',
  `data` text DEFAULT NULL COMMENT 'Serialized session data (JSON)',
  `ip_address` varchar(45) DEFAULT NULL COMMENT 'Client IP address (supports IPv6)',
  `user_agent` text DEFAULT NULL COMMENT 'Client user agent string for security tracking',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`session_id`),
  KEY `idx_user_sessions` (`user_id`),
  KEY `idx_session_expires` (`expires`),
  KEY `idx_session_cleanup` (`expires`,`created_at`),
  KEY `idx_ip_tracking` (`ip_address`,`created_at`),
  CONSTRAINT `user_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Server-side session storage for authentication with 30-minute timeout';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL COMMENT 'Unique username for login',
  `email` varchar(100) DEFAULT NULL COMMENT 'User email address (optional)',
  `password_hash` varchar(255) NOT NULL COMMENT 'bcrypt hashed password with individual salt',
  `salt` varchar(255) NOT NULL COMMENT 'Individual password salt for enhanced security',
  `first_name` varchar(50) NOT NULL COMMENT 'User first name',
  `last_name` varchar(50) NOT NULL COMMENT 'User last name',
  `is_active` tinyint(1) DEFAULT 1 COMMENT 'Whether user account is active',
  `failed_login_attempts` int(11) DEFAULT 0 COMMENT 'Failed login attempt count for lockout logic',
  `locked_until` timestamp NULL DEFAULT NULL COMMENT 'Account lockout expiration timestamp',
  `last_login` timestamp NULL DEFAULT NULL COMMENT 'Last successful login timestamp',
  `password_changed_at` timestamp NULL DEFAULT current_timestamp() COMMENT 'When password was last changed',
  `password_history` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'History of last 5 password hashes to prevent reuse' CHECK (json_valid(`password_history`)),
  `force_password_change` tinyint(1) DEFAULT 0 COMMENT 'Whether user must change password on next login',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_by_user_id` int(11) DEFAULT NULL COMMENT 'User who created this account',
  `updated_by_user_id` int(11) DEFAULT NULL COMMENT 'User who last updated this account',
  `provider_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `email_2` (`email`),
  KEY `idx_username` (`username`),
  KEY `idx_email` (`email`),
  KEY `idx_active_users` (`is_active`,`username`),
  KEY `idx_lockout_check` (`locked_until`,`failed_login_attempts`),
  KEY `idx_login_lookup` (`username`,`is_active`,`locked_until`),
  KEY `idx_provider_id` (`provider_id`),
  CONSTRAINT `users_provider_fk` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User accounts for authentication and authorization system';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping routines for database 'app_database'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-05-06 11:32:42
