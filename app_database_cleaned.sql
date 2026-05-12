-- =====================================================================
-- app_database — CLEANED EXPORT (OpenDental mirror tables removed)
-- =====================================================================
-- Generated: 2026-05-12
-- Source schema: latest2.sql (canonical merge of latest1.sql MariaDB dump
--                + dump_b_canonical_migrations.sql, post-migration 069)
-- Authority for OD comparison: https://www.opendental.com/OpenDentalDocumentation26-1.xml
--                              (OpenDental v26.1.0.0 — 427 native tables)
-- Target: MySQL 8.0 / MariaDB 10.11+ compatible
-- Engine/charset: InnoDB, utf8mb4 (mixed utf8mb4_unicode_ci and
--                 utf8mb4_0900_ai_ci collations preserved per original)
-- =====================================================================
-- DEEP-SCHEMA COMPARISON SUMMARY
-- ---------------------------------------------------------------------
--   Total app_database tables analyzed:                117
--   Native OpenDental tables found (set intersection):   0
--   Mirror/cache tables of OpenDental data EXCLUDED:     2
--   Custom application tables RETAINED:                115
--   Views / triggers / stored procedures / functions:    0   (none in source)
--   Seed INSERT statements added (end-of-file section): 16
--     • 6 system roles (super_admin, admin_user, payroll_manager,
--       payroll_user, insurance_specialist, viewer)
--     • 56 permissions — 54 EXACT @Permissions('...') strings from
--       nest-dental-app/src/**/*.controller.ts + 2 extras only found
--       via hasPermission() / frontend usePermission() (era.post,
--       payroll.view_own) — verified by union-grep on backend + frontend
--     • role_permissions matrix (super_admin gets all; others scoped
--       by actual permission names the code checks for)
--     • 1 sample provider record
--     • 3 default super_admin users — admin / gary / matthew
--       (initial password for all three: "ChangeMe123!"; each has its own
--        bcrypt salt+hash; force_password_change = 1; MUST be rotated)
--     • 15 practice_rule_settings defaults (from migrations 008 + 011)
--     • 6 system_settings entries (app name, timezone, retention, etc.)
--     • 1 stedi_poll_state singleton row (id = 1)
--     • 12 grooming_settings defaults (thresholds + feature flags)
--     • 74 migration_history rows — marks every migration in
--       nest-dental-app/migrations/ as already executed so the runtime
--       migration runner (database-init.service.ts) does not re-apply
--       non-idempotent ALTER statements on first boot. WITHOUT this,
--       the app would attempt to re-run every migration and crash.
-- ---------------------------------------------------------------------
-- EXCLUDED TABLES (OpenDental-derived mirrors)
-- ---------------------------------------------------------------------
--   1. od_insurance_payments
--      Purpose: local cache of OpenDental claimpayment rows
--      PK od_claimpayment_id maps to OD claimpayment.ClaimPaymentNum
--      Columns mirror OD: payment_date, amount, carrier_name, check_number,
--                         payment_type, note, is_partial, claim_count
--      Sync source:  OD REST API (axios via ODFHIR token in database_connections)
--      No FK constraints reference this table (verified line-by-line in source)
--
--   2. od_patient_payments
--      Purpose: local cache of OpenDental payment rows
--      PK od_paynum maps to OD payment.PayNum
--      Columns mirror OD: payment_date, amount, patient_name, pat_num,
--                         check_number, payment_type, payment_type_name,
--                         pay_note, retref, auth_code
--      Sync source:  OD REST API (per migrations 041, 047, 049)
--      No FK constraints reference this table (verified line-by-line in source)
-- ---------------------------------------------------------------------
-- DEPENDENCY ANALYSIS (post-exclusion)
-- ---------------------------------------------------------------------
-- Tables that contain soft-link integer columns (od_claimpayment_id,
-- od_paynum, od_claim_num, od_claimproc_num, od_payment_id, patnum, AptNum,
-- PatNum, ProvNum, FeeSchedNum) remain in this export. These columns are
-- cross-database pointers to the SEPARATE OpenDental MySQL instance
-- (accessed at runtime via mysqlClient.queryOpenDental()). They are NOT
-- enforced foreign keys in app_database, so removing the two local cache
-- mirrors does NOT orphan any FK constraints. No dependency fixes required.
--
-- Tables that retain soft links to OpenDental (for reference):
--   era_payments, era_claims, era_service_lines, era_match_log,
--   era_posting_overrides, posting_results, posting_errors,
--   follow_up_actions, cob_calculation_log, recon_links, recon_links_archive,
--   recon_exceptions, recon_exceptions_archive, remote_deposits,
--   batch_payroll_reports, providers, users, refund_requests, check_register,
--   phi_access_log, grooming_recommendations, grooming_audit_log,
--   grooming_feedback, grooming_membership_verifications,
--   fee_schedule_settings  (PK fee_sched_num shadows OD FeeSchedNum)
--
-- These are CUSTOM application tables (audit, ERA processing, banking
-- reconciliation, payroll, grooming workflow, refund processing, security
-- logs) — not OpenDental tables.
-- ---------------------------------------------------------------------
-- IMPORT VALIDATION
-- ---------------------------------------------------------------------
-- • All CREATE TABLE statements use `IF NOT EXISTS` (idempotent re-import).
-- • FOREIGN_KEY_CHECKS / UNIQUE_CHECKS toggled correctly at file boundaries
--   (matches the original dump's session-restore semantics).
-- • Two collations coexist (utf8mb4_unicode_ci legacy, utf8mb4_0900_ai_ci
--   modern) — both supported by MySQL 8.0+ and MariaDB 10.6+.
-- • Generated columns, JSON CHECK constraints, and ENUM definitions
--   preserved exactly as in source.
-- • Money columns preserved at full DECIMAL precision (no narrowing).
-- =====================================================================

-- =====================================================================
-- CANONICAL SCHEMA — merged from latest1.sql (MariaDB 10.11) and
-- dump_b_canonical_migrations.sql (MySQL 8.0, post-migration 061).
-- Authority: dump_b for tables present in both; latest1 for tables
-- only in latest1 (grooming_*, payroll_settings, phi_access_log,
-- ortho_lab_fees). Charset/collation upgraded to utf8mb4_0900_ai_ci
-- where dump_b uses it; legacy utf8mb4_unicode_ci preserved for tables
-- inherited from latest1 (R3 only upgrades, never downgrades).
-- Money columns preserved at full precision (R1a, no narrowing).
-- All tables use ENGINE=InnoDB, CHARSET=utf8mb4 (R6).
-- =====================================================================

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- ---------------------------------------------------------------
-- Section 1: Identity / RBAC parents (users, providers, roles, permissions)
-- ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `providers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `open_dental_provnum` int DEFAULT NULL,
  `provider_type` enum('endodontist','general_dentist','oral_surgeon','hygienist') NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `open_dental_provnum` (`open_dental_provnum`),
  KEY `idx_provider_type` (`provider_type`),
  KEY `idx_active_providers` (`is_active`),
  KEY `idx_open_dental_provnum` (`open_dental_provnum`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL COMMENT 'Unique username for login',
  `email` varchar(100) DEFAULT NULL COMMENT 'User email address (optional)',
  `password_hash` varchar(255) NOT NULL COMMENT 'bcrypt hashed password with individual salt',
  `salt` varchar(255) NOT NULL COMMENT 'Individual password salt for enhanced security',
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `failed_login_attempts` int DEFAULT '0',
  `locked_until` timestamp NULL DEFAULT NULL,
  `last_login` timestamp NULL DEFAULT NULL,
  `password_changed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `password_history` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'History of last 5 password hashes to prevent reuse',
  `force_password_change` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by_user_id` int DEFAULT NULL,
  `updated_by_user_id` int DEFAULT NULL,
  `provider_id` int DEFAULT NULL,
  `open_dental_usernum` int DEFAULT NULL COMMENT 'Links to userod.UserNum in Open Dental',
  `open_dental_tasklistnum` int DEFAULT NULL COMMENT 'Links to tasklist.TaskListNum (personal inbox) — present in production via manual ALTER, not in repo migrations',
  `entra_object_id` varchar(36) DEFAULT NULL COMMENT 'Azure Entra ID object ID (GUID) for EasyAuth SSO — production column from migration 029 (depends on open_dental_tasklistnum)',
  `open_dental_username` varchar(255) DEFAULT NULL COMMENT 'Links to userod.UserName in Open Dental',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `idx_od_usernum` (`open_dental_usernum`),
  UNIQUE KEY `idx_entra_object_id` (`entra_object_id`),
  KEY `idx_username` (`username`),
  KEY `idx_email` (`email`),
  KEY `idx_active_users` (`is_active`,`username`),
  KEY `idx_lockout_check` (`locked_until`,`failed_login_attempts`),
  KEY `idx_login_lookup` (`username`,`is_active`,`locked_until`),
  KEY `idx_provider_id` (`provider_id`),
  KEY `idx_od_username` (`open_dental_username`),
  KEY `idx_od_tasklistnum` (`open_dental_tasklistnum`),
  CONSTRAINT `users_provider_fk` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE SET NULL,
  CONSTRAINT `users_chk_1` CHECK (json_valid(`password_history`))
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User accounts for authentication and authorization system';

CREATE TABLE IF NOT EXISTS `roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) NOT NULL,
  `display_name` varchar(100) NOT NULL,
  `description` text,
  `is_system_role` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_reviewed_at` timestamp NULL DEFAULT NULL,
  `review_frequency_days` int DEFAULT '90',
  PRIMARY KEY (`id`),
  UNIQUE KEY `role_name` (`role_name`),
  KEY `idx_role_name` (`role_name`),
  KEY `idx_system_roles` (`is_system_role`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='User roles for role-based authorization system';

CREATE TABLE IF NOT EXISTS `permissions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `permission_name` varchar(100) NOT NULL,
  `display_name` varchar(150) NOT NULL,
  `description` text,
  `category` varchar(50) NOT NULL,
  `resource_type` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `permission_name` (`permission_name`),
  KEY `idx_permission_name` (`permission_name`),
  KEY `idx_category` (`category`),
  KEY `idx_resource_type` (`resource_type`),
  KEY `idx_category_resource` (`category`,`resource_type`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='System permissions for granular access control';

CREATE TABLE IF NOT EXISTS `role_permissions` (
  `role_id` int NOT NULL,
  `permission_id` int NOT NULL,
  `granted_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `granted_by_user_id` int DEFAULT NULL,
  PRIMARY KEY (`role_id`,`permission_id`),
  KEY `idx_role_permissions` (`role_id`),
  KEY `idx_permission_roles` (`permission_id`),
  CONSTRAINT `role_permissions_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
  CONSTRAINT `role_permissions_ibfk_2` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `role_hierarchy` (
  `id` int NOT NULL AUTO_INCREMENT,
  `parent_role_id` int NOT NULL,
  `child_role_id` int NOT NULL,
  `created_by_user_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_hierarchy_relationship` (`parent_role_id`,`child_role_id`),
  KEY `idx_parent_role` (`parent_role_id`),
  KEY `idx_child_role` (`child_role_id`),
  KEY `idx_created_by` (`created_by_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `role_permission_cache` (
  `id` int NOT NULL AUTO_INCREMENT,
  `role_id` int NOT NULL,
  `permission_name` varchar(100) NOT NULL,
  `cached_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_role_permission_cache` (`role_id`,`permission_name`),
  KEY `idx_role_cache` (`role_id`),
  KEY `idx_permission_cache` (`permission_name`),
  KEY `idx_cached_at` (`cached_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `permission_conflicts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `role_id` int NOT NULL,
  `permission_name` varchar(100) NOT NULL,
  `conflict_type` enum('REDUNDANT_DIRECT','MULTIPLE_INHERITANCE','CIRCULAR_DEPENDENCY') NOT NULL,
  `conflicting_role_id` int DEFAULT NULL,
  `details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `severity` enum('LOW','MEDIUM','HIGH') DEFAULT 'MEDIUM',
  `status` enum('ACTIVE','RESOLVED','IGNORED') DEFAULT 'ACTIVE',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `resolved_by_user_id` int DEFAULT NULL,
  `resolution_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  PRIMARY KEY (`id`),
  KEY `conflicting_role_id` (`conflicting_role_id`),
  KEY `resolved_by_user_id` (`resolved_by_user_id`),
  KEY `idx_role_conflict` (`role_id`),
  KEY `idx_permission_conflict` (`permission_name`),
  KEY `idx_conflict_status` (`status`),
  KEY `idx_conflict_severity` (`severity`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `permission_conflicts_chk_1` CHECK (json_valid(`details`)),
  CONSTRAINT `permission_conflicts_chk_2` CHECK (json_valid(`resolution_details`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `permission_reviews` (
  `id` int NOT NULL AUTO_INCREMENT,
  `role_id` int NOT NULL,
  `reviewer_user_id` int NOT NULL,
  `status` enum('IN_PROGRESS','COMPLETED','CANCELLED') DEFAULT 'IN_PROGRESS',
  `started_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `completed_at` timestamp NULL DEFAULT NULL,
  `findings` text,
  `recommendations` text,
  `approved_permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_role_review` (`role_id`),
  KEY `idx_reviewer` (`reviewer_user_id`),
  KEY `idx_review_status` (`status`),
  KEY `idx_started_at` (`started_at`),
  CONSTRAINT `permission_reviews_chk_1` CHECK (json_valid(`approved_permissions`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `user_roles` (
  `user_id` int NOT NULL,
  `role_id` int NOT NULL,
  `assigned_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `assigned_by_user_id` int DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`user_id`,`role_id`),
  KEY `idx_user_roles` (`user_id`),
  KEY `idx_role_users` (`role_id`),
  KEY `idx_assigned_by` (`assigned_by_user_id`),
  KEY `idx_role_expiration` (`expires_at`),
  CONSTRAINT `user_roles_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_roles_ibfk_2` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `user_providers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `provider_id` int NOT NULL,
  `relationship_type` enum('self','manager','assistant','admin') DEFAULT 'self',
  `is_primary` tinyint(1) DEFAULT '0',
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by_user_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_provider` (`user_id`,`provider_id`),
  KEY `idx_user_providers` (`user_id`),
  KEY `idx_provider_users` (`provider_id`),
  KEY `idx_relationship_type` (`relationship_type`),
  KEY `idx_primary_relationships` (`is_primary`,`user_id`),
  CONSTRAINT `user_providers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_providers_ibfk_2` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_providers_chk_1` CHECK (json_valid(`permissions`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `user_sessions` (
  `session_id` varchar(128) NOT NULL,
  `user_id` int DEFAULT NULL,
  `expires` bigint NOT NULL COMMENT 'Session expiration timestamp in milliseconds',
  `data` text,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`session_id`),
  KEY `idx_user_sessions` (`user_id`),
  KEY `idx_session_expires` (`expires`),
  KEY `idx_session_cleanup` (`expires`,`created_at`),
  KEY `idx_ip_tracking` (`ip_address`,`created_at`),
  CONSTRAINT `user_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sessions` (
  `session_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `expires` int unsigned NOT NULL,
  `data` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  PRIMARY KEY (`session_id`),
  KEY `idx_sessions_expires` (`expires`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `session_metadata` (
  `session_id` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `user_id` int DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`session_id`),
  KEY `user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `password_resets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `reset_by_user_id` int DEFAULT NULL,
  `reset_type` enum('ADMIN_RESET','USER_REQUEST','SYSTEM_FORCED') NOT NULL DEFAULT 'USER_REQUEST',
  `reason` text,
  `temporary_password_set` tinyint(1) NOT NULL DEFAULT '0',
  `force_change_required` tinyint(1) NOT NULL DEFAULT '1',
  `token` varchar(255) DEFAULT NULL,
  `token_expires_at` datetime DEFAULT NULL,
  `used_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_password_resets_reset_by` (`reset_by_user_id`),
  KEY `idx_password_resets_user_id` (`user_id`),
  KEY `idx_password_resets_created_at` (`created_at`),
  KEY `idx_password_resets_token` (`token`(250)),
  KEY `idx_password_resets_token_expires` (`token_expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `login_attempts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `ip_address` varchar(45) NOT NULL,
  `success` tinyint(1) NOT NULL,
  `failure_reason` varchar(100) DEFAULT NULL,
  `user_agent` text,
  `session_id` varchar(128) DEFAULT NULL,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_username_attempts` (`username`,`timestamp`),
  KEY `idx_ip_attempts` (`ip_address`,`timestamp`),
  KEY `idx_failed_attempts` (`success`,`timestamp`),
  KEY `idx_cleanup_attempts` (`timestamp`),
  KEY `idx_security_monitoring` (`ip_address`,`success`,`timestamp`),
  KEY `idx_login_attempts_username_timestamp` (`username`,`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `action_type` varchar(50) NOT NULL,
  `resource_type` varchar(50) DEFAULT NULL,
  `resource_id` varchar(100) DEFAULT NULL,
  `details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text,
  `session_id` varchar(128) DEFAULT NULL,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `record_hash` varchar(64) DEFAULT NULL COMMENT 'SHA-256 hash of record content for tamper detection — present in production, not in repo migrations',
  PRIMARY KEY (`id`),
  KEY `idx_user_audit` (`user_id`,`timestamp`),
  KEY `idx_action_audit` (`action_type`,`timestamp`),
  KEY `idx_resource_audit` (`resource_type`,`resource_id`),
  KEY `idx_timestamp_audit` (`timestamp`),
  KEY `idx_session_audit` (`session_id`,`timestamp`),
  KEY `idx_audit_logs_timestamp` (`timestamp`),
  KEY `idx_audit_logs_user_timestamp` (`user_id`,`timestamp`),
  KEY `idx_audit_record_hash` (`record_hash`),
  KEY `idx_audit_ip_address` (`ip_address`,`timestamp`),
  CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `audit_logs_chk_1` CHECK (json_valid(`details`))
) ENGINE=InnoDB AUTO_INCREMENT=2385 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `user_activity` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `activity_type` varchar(50) NOT NULL,
  `description` text NOT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_activity_user_id` (`user_id`),
  KEY `idx_user_activity_type` (`activity_type`),
  KEY `idx_user_activity_created_at` (`created_at`),
  KEY `idx_user_activity_user_created` (`user_id`,`created_at`),
  CONSTRAINT `user_activity_chk_1` CHECK (json_valid(`metadata`))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `phi_access_log` (
  `log_id` bigint NOT NULL AUTO_INCREMENT,
  `timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'When the action occurred',
  `username` varchar(50) NOT NULL,
  `user_id` int DEFAULT NULL COMMENT 'FK to users table (NULL if user deleted)',
  `action_type` varchar(50) NOT NULL,
  `PatNum` bigint DEFAULT NULL,
  `description` varchar(500) NOT NULL,
  `success` tinyint(1) NOT NULL DEFAULT '1',
  `error_message` varchar(255) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `idx_phi_log_timestamp` (`timestamp`),
  KEY `idx_phi_log_username` (`username`),
  KEY `idx_phi_log_patnum` (`PatNum`),
  KEY `idx_phi_log_action_type` (`action_type`),
  KEY `idx_phi_log_success` (`success`),
  KEY `idx_phi_log_patnum_timestamp` (`PatNum`,`timestamp`),
  KEY `idx_phi_log_username_timestamp` (`username`,`timestamp`)
) ENGINE=InnoDB AUTO_INCREMENT=13790 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='HIPAA audit trail for PHI access via API operations - 6 year retention required';

CREATE TABLE IF NOT EXISTS `system_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text,
  `setting_type` enum('string','number','boolean','json') DEFAULT 'string',
  `description` text,
  `is_encrypted` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`),
  KEY `idx_setting_key` (`setting_key`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `database_connections` (
  `id` int NOT NULL AUTO_INCREMENT,
  `connection_label` varchar(100) NOT NULL,
  `connection_type` enum('database','api') NOT NULL DEFAULT 'database',
  `system_type` varchar(100) NOT NULL,
  `access_level` enum('read-only','read-write') DEFAULT 'read-only',
  `is_default` tinyint(1) DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '0',
  `description` text,
  `db_host` varchar(255) DEFAULT NULL,
  `db_port` int DEFAULT '3306',
  `db_name` varchar(100) DEFAULT NULL,
  `db_user` varchar(100) DEFAULT NULL,
  `db_password_encrypted` text,
  `api_base_url` varchar(255) DEFAULT NULL,
  `api_auth_type` enum('odfhir','bearer-token','api-key','basic-auth','oauth','custom-header') DEFAULT NULL,
  `api_token_encrypted` text,
  `api_username` varchar(100) DEFAULT NULL,
  `api_password_encrypted` text,
  `api_custom_auth_value_encrypted` text,
  `oauth_client_id` varchar(255) DEFAULT NULL,
  `oauth_client_secret_encrypted` text,
  `oauth_refresh_token_encrypted` text,
  `oauth_redirect_uri` varchar(255) DEFAULT NULL,
  `api_test_endpoint` varchar(255) DEFAULT '/ping',
  `api_test_method` enum('GET','POST','PUT','DELETE') DEFAULT 'GET',
  `api_test_expected_response` text,
  `configuration_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `test_status` enum('pending','success','failed') DEFAULT 'pending',
  `test_results` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `last_tested_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_connection_label` (`connection_label`),
  KEY `idx_system_type` (`system_type`),
  KEY `idx_connection_type` (`connection_type`),
  KEY `idx_active_connections` (`is_active`),
  KEY `idx_test_status` (`test_status`),
  CONSTRAINT `database_connections_chk_1` CHECK (json_valid(`configuration_json`)),
  CONSTRAINT `database_connections_chk_2` CHECK (json_valid(`test_results`))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `migration_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `migration_name` varchar(255) NOT NULL,
  `executed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `execution_time_ms` int DEFAULT NULL,
  `success` tinyint(1) DEFAULT '1',
  `error_message` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_migration_name` (`migration_name`),
  KEY `idx_executed_at` (`executed_at`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `migration_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `migration_name` varchar(255) NOT NULL,
  `executed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `description` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `migration_name` (`migration_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------
-- Section 2: Payroll / compensation / audit tables
-- ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `compensation_rates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `provider_id` int NOT NULL,
  `rate_type` enum('compensation','daily_guarantee') NOT NULL DEFAULT 'compensation',
  `procedure_category` enum('standard','hygiene','restorative','ortho') NOT NULL DEFAULT 'standard',
  `compensation_percentage` decimal(5,2) NOT NULL DEFAULT '0.00',
  `daily_guarantee_rate` decimal(10,2) NOT NULL DEFAULT '0.00',
  `effective_date` date NOT NULL,
  `notes` text,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_provider_rates` (`provider_id`,`effective_date`,`is_active`),
  KEY `idx_rate_type` (`rate_type`,`procedure_category`),
  KEY `idx_active_rates` (`is_active`,`effective_date`),
  CONSTRAINT `compensation_rates_ibfk_1` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `doctor_days_worked` (
  `id` int NOT NULL AUTO_INCREMENT,
  `provider_id` int NOT NULL,
  `pay_period_start` date NOT NULL,
  `pay_period_end` date NOT NULL,
  `days_worked` int NOT NULL DEFAULT '0',
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_provider_pay_period` (`provider_id`,`pay_period_start`,`pay_period_end`),
  KEY `idx_provider_periods` (`provider_id`,`pay_period_start`,`pay_period_end`),
  KEY `idx_pay_period_range` (`pay_period_start`,`pay_period_end`),
  KEY `idx_doctor_days_provider_period` (`provider_id`,`pay_period_start`),
  CONSTRAINT `doctor_days_worked_ibfk_1` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_days_worked_positive` CHECK ((`days_worked` >= 0)),
  CONSTRAINT `chk_days_worked_reasonable` CHECK ((`days_worked` <= 31)),
  CONSTRAINT `chk_pay_period_order` CHECK ((`pay_period_start` <= `pay_period_end`))
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `hygienist_bonus_rates` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bonus_type` varchar(50) NOT NULL,
  `procedure_code` varchar(20) DEFAULT NULL,
  `bonus_name` varchar(100) NOT NULL,
  `bonus_rate` decimal(10,2) NOT NULL DEFAULT '0.00',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `calculation_method` enum('per_procedure','per_patient','flat_rate') NOT NULL DEFAULT 'per_procedure',
  `description` text,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `excluded_carriers` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `bonus_type` (`bonus_type`),
  KEY `is_active` (`is_active`),
  KEY `procedure_code` (`procedure_code`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `hygienist_extra_patients` (
  `id` int NOT NULL AUTO_INCREMENT,
  `provider_id` int NOT NULL,
  `work_date` date NOT NULL,
  `extra_patient_count` int NOT NULL,
  `rate_per_patient` decimal(10,2) NOT NULL,
  `bonus_amount` decimal(10,2) GENERATED ALWAYS AS ((`extra_patient_count` * `rate_per_patient`)) STORED,
  `pay_period_start` date NOT NULL,
  `pay_period_end` date NOT NULL,
  `notes` text,
  `approved_by` int DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_provider_date` (`provider_id`,`work_date`),
  KEY `idx_provider_date` (`provider_id`,`work_date`),
  KEY `idx_provider_period` (`provider_id`,`pay_period_start`,`pay_period_end`),
  KEY `idx_period` (`pay_period_start`,`pay_period_end`),
  KEY `idx_approved` (`approved_by`,`approved_at`),
  KEY `idx_hygienist_extra_patients_active` (`is_active`),
  KEY `idx_hygienist_extra_patients_period_active` (`pay_period_start`,`pay_period_end`,`is_active`),
  KEY `idx_hygienist_extra_provider_date` (`provider_id`,`work_date`),
  CONSTRAINT `chk_extra_patients` CHECK (((`extra_patient_count` > 0) and (`extra_patient_count` <= 8))),
  CONSTRAINT `chk_rate` CHECK ((`rate_per_patient` > 0)),
  CONSTRAINT `chk_work_date_in_period` CHECK (((`work_date` >= `pay_period_start`) and (`work_date` <= `pay_period_end`)))
) ENGINE=InnoDB AUTO_INCREMENT=233 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `oral_surgeon_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `setting_type` enum('flat_rate','production_exclusion','general_setting') NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text NOT NULL,
  `display_name` varchar(255) DEFAULT NULL,
  `description` text,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_setting` (`setting_type`,`setting_key`),
  KEY `idx_setting_type` (`setting_type`),
  KEY `idx_is_active` (`is_active`),
  KEY `idx_setting_key` (`setting_key`),
  CONSTRAINT `oral_surgeon_settings_chk_1` CHECK (json_valid(`metadata`))
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ortho_lab_fees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `procedure_name` varchar(255) NOT NULL,
  `procedure_code` varchar(50) NOT NULL,
  `fee_amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `effective_date` date NOT NULL DEFAULT (curdate()),
  `end_date` date DEFAULT NULL,
  `description` text,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_procedure_code` (`procedure_code`),
  KEY `idx_active_fees` (`is_active`),
  KEY `idx_procedure_name` (`procedure_name`),
  KEY `idx_ortho_fees_temporal` (`procedure_code`,`effective_date`,`end_date`),
  KEY `idx_ortho_fees_active` (`procedure_code`,`end_date`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `payroll_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `setting_type` enum('provider_specific','provider_type','adjustment_rule','procedure_codes') NOT NULL,
  `setting_category` varchar(50) NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `provider_id` int DEFAULT NULL,
  `provider_type` varchar(50) DEFAULT NULL,
  `setting_value` text NOT NULL,
  `display_name` varchar(255) DEFAULT NULL,
  `description` text,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `effective_date` date NOT NULL DEFAULT (curdate()),
  `end_date` date DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_provider_settings` (`provider_id`,`setting_type`,`effective_date`),
  KEY `idx_provider_type_settings` (`provider_type`,`setting_category`,`effective_date`),
  KEY `idx_temporal_lookup` (`effective_date`,`end_date`),
  KEY `idx_active_settings` (`is_active`,`setting_type`,`setting_category`),
  KEY `idx_setting_search` (`setting_category`,`setting_key`),
  CONSTRAINT `payroll_settings_ibfk_1` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `payroll_settings_chk_1` CHECK (json_valid(`metadata`))
) ENGINE=InnoDB AUTO_INCREMENT=1488 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `provider_additions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `provider_id` int NOT NULL,
  `provider_type` varchar(50) DEFAULT 'oral_surgeon',
  `date` date NOT NULL,
  `amount` decimal(10,2) NOT NULL DEFAULT '0.00',
  `note` text,
  `category` varchar(50) DEFAULT 'manual_addition',
  `reference_id` varchar(100) DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `idx_provider_date` (`provider_id`,`date`),
  KEY `idx_provider_type_date` (`provider_type`,`date`),
  KEY `idx_date_range` (`date`)
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `provider_adjustment_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `provider_type` enum('endodontist','general_dentist','oral_surgeon','hygienist') NOT NULL,
  `procedure_category` varchar(50) NOT NULL DEFAULT 'all',
  `adjustment_type` varchar(100) DEFAULT NULL,
  `adjustment_category` varchar(50) DEFAULT NULL,
  `adjustment_type_id` int NOT NULL,
  `adjustment_name` varchar(100) DEFAULT NULL,
  `is_included` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `procedure_codes` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_provider_category_adjustment` (`provider_type`,`procedure_category`,`adjustment_type_id`),
  KEY `idx_provider_type_adj` (`provider_type`),
  KEY `idx_adjustment_type` (`adjustment_type_id`),
  KEY `idx_provider_settings_covering` (`provider_type`,`adjustment_type_id`,`is_included`,`procedure_category`,`adjustment_name`),
  KEY `idx_provider_inclusion_lookup` (`provider_type`,`is_included`,`adjustment_type_id`),
  CONSTRAINT `provider_adjustment_settings_chk_1` CHECK (json_valid(`procedure_codes`))
) ENGINE=InnoDB AUTO_INCREMENT=2845 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `provider_time_entries` (
  `id` int NOT NULL AUTO_INCREMENT,
  `provider_id` int NOT NULL,
  `entry_date` date NOT NULL,
  `pay_period_start` date NOT NULL,
  `pay_period_end` date NOT NULL,
  `time_type` enum('base','education','sick','vacation','other') NOT NULL,
  `hours` decimal(4,2) NOT NULL,
  `notes` text,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_provider_date_type` (`provider_id`,`entry_date`,`time_type`),
  KEY `idx_provider_period` (`provider_id`,`pay_period_start`,`pay_period_end`),
  KEY `idx_time_type` (`time_type`),
  KEY `idx_entry_date` (`entry_date`),
  KEY `idx_active_entries` (`is_active`,`entry_date`),
  KEY `idx_provider_active` (`provider_id`,`is_active`),
  CONSTRAINT `provider_time_entries_ibfk_1` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_date_in_period` CHECK ((`entry_date` between `pay_period_start` and `pay_period_end`)),
  CONSTRAINT `chk_hours_positive` CHECK ((`hours` > 0)),
  CONSTRAINT `chk_hours_reasonable` CHECK ((`hours` <= 8))
) ENGINE=InnoDB AUTO_INCREMENT=680 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `payroll_calculations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `provider_id` int NOT NULL,
  `calculation_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `gross_production` decimal(10,2) DEFAULT '0.00',
  `net_production` decimal(10,2) DEFAULT '0.00',
  `adjustments_total` decimal(10,2) DEFAULT '0.00',
  `writeoffs_total` decimal(10,2) DEFAULT '0.00',
  `final_compensation` decimal(10,2) NOT NULL,
  `total_payment` decimal(10,2) NOT NULL,
  `calculation_method` varchar(50) DEFAULT NULL,
  `calculation_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_calc_provider` (`provider_id`),
  KEY `idx_calc_period` (`start_date`,`end_date`),
  KEY `idx_calc_created` (`created_at`),
  CONSTRAINT `payroll_calculations_ibfk_1` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `payroll_calculations_chk_1` CHECK (json_valid(`calculation_data`))
) ENGINE=InnoDB AUTO_INCREMENT=329 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `payroll_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `provider_id` int NOT NULL,
  `period_start_date` date NOT NULL,
  `period_end_date` date NOT NULL,
  `gross_production` decimal(10,2) DEFAULT '0.00',
  `adjustments` decimal(10,2) DEFAULT '0.00',
  `writeoffs` decimal(10,2) DEFAULT '0.00',
  `net_production` decimal(10,2) DEFAULT '0.00',
  `production_pay` decimal(10,2) NOT NULL,
  `daily_guarantee` decimal(10,2) NOT NULL,
  `pto_pay` decimal(10,2) DEFAULT '0.00',
  `total_pay` decimal(10,2) NOT NULL,
  `report_status` enum('draft','finalized','approved','paid') DEFAULT 'draft',
  `notes` text,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `provider_id` (`provider_id`),
  KEY `idx_report_period` (`period_start_date`,`period_end_date`),
  KEY `idx_report_status` (`report_status`),
  CONSTRAINT `payroll_reports_ibfk_1` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `adjustment_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `adjustment_type_id` int NOT NULL,
  `adjustment_name` varchar(255) NOT NULL,
  `is_included_by_default` tinyint(1) DEFAULT '1',
  `category` enum('discount','credit','insurance','other') DEFAULT 'other',
  `description` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `adjustment_type_id` (`adjustment_type_id`),
  KEY `idx_adjustment_type_settings` (`adjustment_type_id`),
  KEY `idx_adjustment_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------
-- Section 3: Quarterly audit, batch payroll, audit_adjustments
-- ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `quarterly_audit_runs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `quarter` tinyint NOT NULL,
  `year` int NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` enum('pending','processing','completed','failed','cancelled') NOT NULL DEFAULT 'pending',
  `progress` int DEFAULT '0',
  `total_providers` int DEFAULT '0',
  `processed_providers` int DEFAULT '0',
  `zip_file_path` varchar(500) DEFAULT NULL,
  `summary_pdf_path` varchar(500) DEFAULT NULL,
  `error_message` text,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_quarter_year` (`quarter`,`year`),
  KEY `idx_quarter_year` (`quarter`,`year`),
  KEY `idx_status` (`status`),
  KEY `idx_created_by` (`created_by`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `fk_audit_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `chk_progress_range` CHECK (((`progress` >= 0) and (`progress` <= 100))),
  CONSTRAINT `chk_providers_count` CHECK ((`processed_providers` <= `total_providers`)),
  CONSTRAINT `chk_quarter_valid` CHECK (((`quarter` >= 1) and (`quarter` <= 4))),
  CONSTRAINT `chk_year_valid` CHECK (((`year` >= 2024) and (`year` <= 2099)))
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `batch_payroll_runs` (
  `id` varchar(36) NOT NULL,
  `requested_by` int DEFAULT NULL,
  `requested_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `pay_period_start` date NOT NULL,
  `pay_period_end` date NOT NULL,
  `provider_ids` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `total_providers` int NOT NULL,
  `status` enum('queued','processing','completed','failed','cancelled') NOT NULL DEFAULT 'queued',
  `report_type` enum('regular','quarterly_audit') DEFAULT 'regular',
  `providers_processed` int DEFAULT '0',
  `providers_failed` int DEFAULT '0',
  `current_provider_id` int DEFAULT NULL,
  `current_provider_name` varchar(255) DEFAULT NULL,
  `started_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `estimated_completion` timestamp NULL DEFAULT NULL,
  `options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `fail_fast` tinyint(1) DEFAULT '1',
  `total_compensation` decimal(10,2) DEFAULT NULL,
  `total_base_pay` decimal(10,2) DEFAULT NULL,
  `total_bonuses` decimal(10,2) DEFAULT NULL,
  `total_deductions` decimal(10,2) DEFAULT NULL,
  `error_message` text,
  `error_provider_id` int DEFAULT NULL,
  `error_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `processing_duration_ms` int DEFAULT NULL,
  `avg_provider_duration_ms` int DEFAULT NULL,
  `memory_usage_mb` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `summary_pdf_path` varchar(500) DEFAULT NULL,
  `batch_zip_path` varchar(500) DEFAULT NULL,
  `pdf_generation_started_at` timestamp NULL DEFAULT NULL,
  `pdf_generation_completed_at` timestamp NULL DEFAULT NULL,
  `pdf_generation_duration_ms` int DEFAULT NULL,
  `pdf_error_message` text,
  `pdf_error_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `total_pdfs_generated` int DEFAULT '0',
  `total_pdf_failures` int DEFAULT '0',
  `pdf_generation_status` enum('pending','processing','completed','failed') DEFAULT 'pending',
  `audit_adjustments_applied` tinyint(1) DEFAULT '0',
  `audit_run_id` int DEFAULT NULL,
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
  CONSTRAINT `fk_batch_audit_run` FOREIGN KEY (`audit_run_id`) REFERENCES `quarterly_audit_runs` (`id`) ON DELETE SET NULL,
  CONSTRAINT `batch_payroll_runs_chk_1` CHECK (json_valid(`provider_ids`)),
  CONSTRAINT `batch_payroll_runs_chk_2` CHECK (json_valid(`options`)),
  CONSTRAINT `batch_payroll_runs_chk_3` CHECK (json_valid(`error_details`)),
  CONSTRAINT `batch_payroll_runs_chk_4` CHECK (json_valid(`pdf_error_details`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `batch_payroll_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `batch_run_id` varchar(36) NOT NULL,
  `provider_id` int NOT NULL,
  `provider_name` varchar(255) NOT NULL,
  `provider_type` varchar(100) NOT NULL,
  `open_dental_provnum` int DEFAULT NULL,
  `pay_period_start` date NOT NULL,
  `pay_period_end` date NOT NULL,
  `total_pay` decimal(10,2) DEFAULT '0.00',
  `base_pay` decimal(10,2) DEFAULT '0.00',
  `bonuses` decimal(10,2) DEFAULT '0.00',
  `deductions` decimal(10,2) DEFAULT '0.00',
  `calculation_status` enum('pending','processing','completed','failed') NOT NULL DEFAULT 'pending',
  `error_message` text,
  `error_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `calculation_started_at` timestamp NULL DEFAULT NULL,
  `calculation_completed_at` timestamp NULL DEFAULT NULL,
  `calculation_duration_ms` int DEFAULT NULL,
  `provider_specific_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `calculation_metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `adapter_version` varchar(50) DEFAULT '1.0.0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `pdf_file_path` varchar(500) DEFAULT NULL,
  `pdf_generation_started_at` timestamp NULL DEFAULT NULL,
  `pdf_generation_completed_at` timestamp NULL DEFAULT NULL,
  `pdf_generation_error` text,
  `pdf_generation_status` enum('pending','processing','completed','failed') DEFAULT 'pending',
  PRIMARY KEY (`id`),
  KEY `idx_batch_reports_batch_run` (`batch_run_id`),
  KEY `idx_batch_reports_provider` (`provider_id`),
  KEY `idx_batch_reports_status` (`calculation_status`),
  KEY `idx_batch_reports_processed_at` (`calculation_completed_at`),
  KEY `idx_batch_reports_pdf_timing` (`pdf_generation_started_at`,`pdf_generation_completed_at`),
  KEY `idx_batch_reports_pdf_status` (`batch_run_id`,`pdf_generation_status`),
  KEY `idx_batch_reports_provider_category` (`batch_run_id`,`provider_type`),
  KEY `idx_batch_reports_file_path` (`pdf_file_path`),
  KEY `idx_batch_reports_pdf_errors` (`pdf_generation_status`,`pdf_generation_error`(255)),
  CONSTRAINT `batch_payroll_reports_chk_1` CHECK (json_valid(`error_details`)),
  CONSTRAINT `batch_payroll_reports_chk_2` CHECK (json_valid(`provider_specific_data`)),
  CONSTRAINT `batch_payroll_reports_chk_3` CHECK (json_valid(`calculation_metadata`))
) ENGINE=InnoDB AUTO_INCREMENT=1121 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `batch_pdf_files` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `batch_id` varchar(36) NOT NULL,
  `provider_id` int DEFAULT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_size` bigint DEFAULT NULL,
  `file_type` enum('individual','summary','archive') NOT NULL DEFAULT 'individual',
  `employment_category` enum('Employees','Independent_Contractors','Hygienists') DEFAULT NULL,
  `provider_type` varchar(50) DEFAULT NULL,
  `pay_period_start` date NOT NULL,
  `pay_period_end` date NOT NULL,
  `generation_status` enum('pending','processing','completed','failed') NOT NULL DEFAULT 'pending',
  `generation_started_at` timestamp NULL DEFAULT NULL,
  `generation_completed_at` timestamp NULL DEFAULT NULL,
  `generation_duration_ms` int DEFAULT NULL,
  `error_message` text,
  `error_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `file_hash` varchar(64) DEFAULT NULL,
  `is_archived` tinyint(1) DEFAULT '0',
  `archive_path` varchar(500) DEFAULT NULL,
  `template_version` varchar(20) DEFAULT NULL,
  `generation_metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `is_downloadable` tinyint(1) DEFAULT '1',
  `download_count` int DEFAULT '0',
  `last_downloaded_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_batch_pdf_files_batch` (`batch_id`),
  KEY `idx_batch_pdf_files_provider` (`provider_id`),
  KEY `idx_batch_pdf_files_category` (`employment_category`),
  KEY `idx_batch_pdf_files_status` (`generation_status`),
  KEY `idx_batch_pdf_files_pay_period` (`pay_period_start`,`pay_period_end`),
  KEY `idx_batch_pdf_files_file_type` (`file_type`),
  KEY `idx_batch_pdf_files_provider_type` (`provider_type`),
  CONSTRAINT `batch_pdf_files_chk_1` CHECK (json_valid(`error_details`)),
  CONSTRAINT `batch_pdf_files_chk_2` CHECK (json_valid(`generation_metadata`))
) ENGINE=InnoDB AUTO_INCREMENT=402 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `quarterly_audit_providers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `audit_run_id` int NOT NULL,
  `provider_id` int NOT NULL,
  `provider_name` varchar(255) NOT NULL,
  `provider_type` varchar(50) NOT NULL,
  `daily_rate` decimal(10,2) DEFAULT NULL,
  `period_1_batch_id` varchar(36) DEFAULT NULL,
  `period_1_date_range` varchar(100) DEFAULT NULL,
  `period_1_amount` decimal(10,2) DEFAULT '0.00',
  `period_2_batch_id` varchar(36) DEFAULT NULL,
  `period_2_date_range` varchar(100) DEFAULT NULL,
  `period_2_amount` decimal(10,2) DEFAULT '0.00',
  `period_3_batch_id` varchar(36) DEFAULT NULL,
  `period_3_date_range` varchar(100) DEFAULT NULL,
  `period_3_amount` decimal(10,2) DEFAULT '0.00',
  `period_4_batch_id` varchar(36) DEFAULT NULL,
  `period_4_date_range` varchar(100) DEFAULT NULL,
  `period_4_amount` decimal(10,2) DEFAULT '0.00',
  `period_5_batch_id` varchar(36) DEFAULT NULL,
  `period_5_date_range` varchar(100) DEFAULT NULL,
  `period_5_amount` decimal(10,2) DEFAULT '0.00',
  `period_6_batch_id` varchar(36) DEFAULT NULL,
  `period_6_date_range` varchar(100) DEFAULT NULL,
  `period_6_amount` decimal(10,2) DEFAULT '0.00',
  `total_paid_across_periods` decimal(10,2) DEFAULT '0.00',
  `missing_periods_count` int DEFAULT '0',
  `missing_periods_warning` text,
  `quarterly_production` decimal(10,2) DEFAULT '0.00',
  `quarterly_days_worked` int DEFAULT '0',
  `quarterly_calculated_amount` decimal(10,2) DEFAULT '0.00',
  `difference` decimal(10,2) DEFAULT '0.00',
  `difference_percentage` decimal(5,2) DEFAULT '0.00',
  `pdf_file_path` varchar(500) DEFAULT NULL,
  `status` enum('pending','processing','completed','failed') DEFAULT 'pending',
  `error_message` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `hygiene_paid_amount` decimal(10,2) DEFAULT '0.00',
  `hygiene_quarterly_amount` decimal(10,2) DEFAULT '0.00',
  `hygiene_difference` decimal(10,2) DEFAULT '0.00',
  `restorative_paid_amount` decimal(10,2) DEFAULT '0.00',
  `restorative_quarterly_amount` decimal(10,2) DEFAULT '0.00',
  `restorative_difference` decimal(10,2) DEFAULT '0.00',
  `ortho_paid_amount` decimal(10,2) DEFAULT '0.00',
  `ortho_quarterly_amount` decimal(10,2) DEFAULT '0.00',
  `ortho_difference` decimal(10,2) DEFAULT '0.00',
  `production_paid_amount` decimal(10,2) DEFAULT '0.00',
  `production_quarterly_amount` decimal(10,2) DEFAULT '0.00',
  `production_difference` decimal(10,2) DEFAULT '0.00',
  `bone_graft_paid_count` int DEFAULT '0',
  `bone_graft_quarterly_count` int DEFAULT '0',
  `bone_graft_count_difference` int DEFAULT '0',
  `bone_graft_paid_amount` decimal(10,2) DEFAULT '0.00',
  `bone_graft_quarterly_amount` decimal(10,2) DEFAULT '0.00',
  `bone_graft_difference` decimal(10,2) DEFAULT '0.00',
  `sedation_paid_count` int DEFAULT '0',
  `sedation_quarterly_count` int DEFAULT '0',
  `sedation_count_difference` int DEFAULT '0',
  `sedation_paid_amount` decimal(10,2) DEFAULT '0.00',
  `sedation_quarterly_amount` decimal(10,2) DEFAULT '0.00',
  `sedation_difference` decimal(10,2) DEFAULT '0.00',
  `additions_paid_amount` decimal(10,2) DEFAULT '0.00',
  `additions_quarterly_amount` decimal(10,2) DEFAULT '0.00',
  `additions_difference` decimal(10,2) DEFAULT '0.00',
  `category_breakdown` json DEFAULT NULL,
  `hygiene_adjustment_amount` decimal(10,2) DEFAULT '0.00',
  `restorative_adjustment_amount` decimal(10,2) DEFAULT '0.00',
  `ortho_adjustment_amount` decimal(10,2) DEFAULT '0.00',
  `production_adjustment_amount` decimal(10,2) DEFAULT '0.00',
  `bone_graft_adjustment_amount` decimal(10,2) DEFAULT '0.00',
  `sedation_adjustment_amount` decimal(10,2) DEFAULT '0.00',
  `additions_adjustment_amount` decimal(10,2) DEFAULT '0.00',
  `total_adjustment_amount` decimal(10,2) DEFAULT '0.00',
  `hygiene_commission_rate` decimal(5,4) DEFAULT NULL,
  `restorative_commission_rate` decimal(5,4) DEFAULT NULL,
  `ortho_commission_rate` decimal(5,4) DEFAULT NULL,
  `production_commission_rate` decimal(5,4) DEFAULT NULL,
  `applied_batch_id` varchar(36) DEFAULT NULL,
  `applied_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `period_1_batch_id` (`period_1_batch_id`),
  KEY `period_2_batch_id` (`period_2_batch_id`),
  KEY `period_3_batch_id` (`period_3_batch_id`),
  KEY `period_4_batch_id` (`period_4_batch_id`),
  KEY `period_5_batch_id` (`period_5_batch_id`),
  KEY `period_6_batch_id` (`period_6_batch_id`),
  KEY `idx_audit_run` (`audit_run_id`),
  KEY `idx_provider` (`provider_id`),
  KEY `idx_status` (`status`),
  KEY `idx_audit_provider` (`audit_run_id`,`provider_id`),
  KEY `idx_audit_providers_applied` (`applied_batch_id`),
  CONSTRAINT `fk_qap_audit_run` FOREIGN KEY (`audit_run_id`) REFERENCES `quarterly_audit_runs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_qap_provider` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `qap_period_1_fk` FOREIGN KEY (`period_1_batch_id`) REFERENCES `batch_payroll_runs` (`id`) ON DELETE SET NULL,
  CONSTRAINT `qap_period_2_fk` FOREIGN KEY (`period_2_batch_id`) REFERENCES `batch_payroll_runs` (`id`) ON DELETE SET NULL,
  CONSTRAINT `qap_period_3_fk` FOREIGN KEY (`period_3_batch_id`) REFERENCES `batch_payroll_runs` (`id`) ON DELETE SET NULL,
  CONSTRAINT `qap_period_4_fk` FOREIGN KEY (`period_4_batch_id`) REFERENCES `batch_payroll_runs` (`id`) ON DELETE SET NULL,
  CONSTRAINT `qap_period_5_fk` FOREIGN KEY (`period_5_batch_id`) REFERENCES `batch_payroll_runs` (`id`) ON DELETE SET NULL,
  CONSTRAINT `qap_period_6_fk` FOREIGN KEY (`period_6_batch_id`) REFERENCES `batch_payroll_runs` (`id`) ON DELETE SET NULL,
  CONSTRAINT `chk_missing_periods_range` CHECK (((`missing_periods_count` >= 0) and (`missing_periods_count` <= 6)))
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `audit_adjustments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `audit_run_id` int NOT NULL,
  `provider_id` int NOT NULL,
  `batch_run_id` varchar(36) DEFAULT NULL,
  `category` varchar(50) NOT NULL,
  `adjustment_amount` decimal(10,2) NOT NULL,
  `quarter` int NOT NULL,
  `year` int NOT NULL,
  `applied_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  CONSTRAINT `fk_aa_provider` FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_aa_batch_run` FOREIGN KEY (`batch_run_id`) REFERENCES `batch_payroll_runs` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=114 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------
-- Section 4: Grooming module (latest1.sql only)
-- ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `grooming_runs` (
  `run_id` bigint NOT NULL AUTO_INCREMENT,
  `target_date` date NOT NULL,
  `end_date` date DEFAULT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime DEFAULT NULL,
  `last_checked_timestamp` datetime DEFAULT NULL,
  `total_appointments` int NOT NULL DEFAULT '0',
  `new_appointments` int NOT NULL DEFAULT '0',
  `total_flags` int NOT NULL DEFAULT '0',
  `status` varchar(20) NOT NULL DEFAULT 'running',
  `triggered_by` int NOT NULL,
  `is_delta_run` tinyint(1) NOT NULL DEFAULT '0',
  `error_message` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `viewed_at` datetime DEFAULT NULL,
  `viewed_by` int DEFAULT NULL,
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
) ENGINE=InnoDB AUTO_INCREMENT=1062 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `grooming_recommendations` (
  `recommendation_id` bigint NOT NULL AUTO_INCREMENT,
  `run_id` bigint DEFAULT NULL,
  `AptNum` bigint NOT NULL,
  `PatNum` bigint NOT NULL,
  `patient_name` varchar(100) NOT NULL,
  `apt_datetime` datetime NOT NULL,
  `apt_DateTStamp` datetime NOT NULL,
  `xray_status` varchar(255) DEFAULT NULL,
  `xray_recommendation` varchar(200) DEFAULT NULL,
  `probing_status` varchar(255) DEFAULT NULL,
  `probing_recommendation` varchar(200) DEFAULT NULL,
  `pano_status` varchar(255) DEFAULT NULL,
  `pano_recommendation` varchar(200) DEFAULT NULL,
  `insurance_status` varchar(100) DEFAULT NULL,
  `insurance_recommendation` varchar(200) DEFAULT NULL,
  `balance_status` varchar(200) DEFAULT NULL,
  `balance_recommendation` varchar(200) DEFAULT NULL,
  `credit_status` varchar(200) DEFAULT NULL,
  `credit_recommendation` varchar(200) DEFAULT NULL,
  `fluoride_status` varchar(100) DEFAULT NULL,
  `fluoride_recommendation` varchar(200) DEFAULT NULL,
  `age_code_status` varchar(100) DEFAULT NULL,
  `age_code_recommendation` varchar(200) DEFAULT NULL,
  `exam_status` varchar(255) DEFAULT NULL,
  `exam_recommendation` varchar(200) DEFAULT NULL,
  `scheduled_exam_codes` varchar(100) DEFAULT NULL,
  `scheduled_exam_procnums` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `scheduled_bwx_codes` varchar(100) DEFAULT NULL,
  `scheduled_bwx_procnums` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `scheduled_probing_codes` varchar(100) DEFAULT NULL,
  `scheduled_probing_procnums` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `scheduled_pano_codes` varchar(100) DEFAULT NULL,
  `scheduled_pano_procnums` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `has_flags` tinyint(1) NOT NULL DEFAULT '0',
  `is_new` tinyint(1) NOT NULL DEFAULT '0',
  `is_new_patient` tinyint(1) NOT NULL DEFAULT '0',
  `is_lapsed_patient` tinyint(1) DEFAULT '0',
  `action_status` varchar(20) NOT NULL DEFAULT 'pending',
  `reviewed_by` int DEFAULT NULL,
  `reviewed_at` datetime DEFAULT NULL,
  `patient_portion` decimal(10,2) DEFAULT NULL,
  `patient_portion_note` varchar(255) DEFAULT NULL,
  `annual_max_remaining` decimal(10,2) DEFAULT NULL,
  `annual_max_status` varchar(20) DEFAULT NULL,
  `waiting_periods` text,
  `membership_status` varchar(20) DEFAULT NULL,
  `generated_note` text,
  `od_appointment_note` text,
  `target_date` date NOT NULL,
  `last_run_id` bigint DEFAULT NULL,
  `is_delta_add` tinyint(1) NOT NULL DEFAULT '0',
  `groomed_at` datetime DEFAULT NULL,
  `groomed_by` int DEFAULT NULL,
  `note_written` tinyint(1) DEFAULT '0',
  `note_written_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `pp_calculation_detail` text,
  `standard_codes_status` varchar(50) DEFAULT NULL,
  `standard_codes_recommendation` varchar(200) DEFAULT NULL,
  `hygiene_status` varchar(50) DEFAULT NULL,
  `hygiene_recommendation` varchar(200) DEFAULT NULL,
  `scheduled_hygiene_codes` varchar(100) DEFAULT NULL,
  `scheduled_hygiene_procnums` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `last_hygiene_code` varchar(10) DEFAULT NULL,
  `scheduled_hygiene_code` varchar(10) DEFAULT NULL,
  `duplicate_tp_status` varchar(50) DEFAULT NULL,
  `duplicate_tp_recommendation` text,
  `duplicate_tp_procnums` text,
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
) ENGINE=InnoDB AUTO_INCREMENT=36625 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `grooming_audit_log` (
  `audit_id` bigint NOT NULL AUTO_INCREMENT,
  `recommendation_id` bigint NOT NULL,
  `AptNum` bigint NOT NULL,
  `PatNum` bigint NOT NULL,
  `action_type` varchar(20) NOT NULL,
  `proc_code` varchar(10) NOT NULL,
  `executed_at` datetime NOT NULL,
  `executed_by` int NOT NULL,
  `success` tinyint(1) NOT NULL DEFAULT '0',
  `api_response` text,
  `error_message` varchar(500) DEFAULT NULL,
  `retry_count` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `grooming_feedback` (
  `feedback_id` bigint NOT NULL AUTO_INCREMENT,
  `recommendation_id` bigint DEFAULT NULL,
  `AptNum` bigint NOT NULL,
  `PatNum` bigint NOT NULL,
  `target_date` date NOT NULL,
  `patient_name` varchar(100) NOT NULL,
  `issue_type` varchar(50) NOT NULL,
  `affected_checks` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `priority` varchar(20) NOT NULL DEFAULT 'medium',
  `user_notes` text NOT NULL,
  `user_fix_notes` text,
  `recommendation_snapshot` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'new',
  `admin_notes` text,
  `resolution_type` varchar(50) DEFAULT NULL,
  `submitted_by` int NOT NULL,
  `reviewed_by` int DEFAULT NULL,
  `resolved_by` int DEFAULT NULL,
  `submitted_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `reviewed_at` datetime DEFAULT NULL,
  `resolved_at` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
  CONSTRAINT `fk_grooming_feedback_submitted_by` FOREIGN KEY (`submitted_by`) REFERENCES `users` (`id`),
  CONSTRAINT `grooming_feedback_chk_1` CHECK (json_valid(`affected_checks`)),
  CONSTRAINT `grooming_feedback_chk_2` CHECK (json_valid(`recommendation_snapshot`))
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `grooming_membership_verifications` (
  `verification_id` bigint NOT NULL AUTO_INCREMENT,
  `PatNum` bigint NOT NULL,
  `DiscountPlanNum` bigint NOT NULL,
  `verified_at` datetime NOT NULL,
  `verified_by` varchar(50) NOT NULL,
  `status` varchar(20) NOT NULL,
  `notes` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`verification_id`),
  KEY `idx_membership_ver_patnum` (`PatNum`),
  KEY `idx_membership_ver_verified_at` (`verified_at`),
  KEY `idx_membership_ver_discountplan` (`DiscountPlanNum`),
  KEY `idx_membership_ver_patnum_plan_date` (`PatNum`,`DiscountPlanNum`,`verified_at`),
  CONSTRAINT `chk_membership_ver_status` CHECK (`status` in ('Active','Inactive','Expired'))
) ENGINE=InnoDB AUTO_INCREMENT=410 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `grooming_settings` (
  `setting_key` varchar(50) NOT NULL,
  `setting_value` varchar(255) NOT NULL,
  `setting_type` varchar(20) NOT NULL,
  `category` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`setting_key`),
  KEY `idx_grooming_settings_category` (`category`),
  CONSTRAINT `chk_grooming_settings_type` CHECK (`setting_type` in ('number','string','boolean'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------
-- Section 5: ERA / claims posting (dump_b only)
-- ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `era_payments` (
  `era_id` int NOT NULL AUTO_INCREMENT,
  `clearinghouse_name` varchar(50) DEFAULT NULL,
  `source` enum('dxc_manual','stedi') NOT NULL DEFAULT 'dxc_manual',
  `stedi_transaction_id` varchar(100) DEFAULT NULL,
  `stedi_file_execution_id` varchar(100) DEFAULT NULL,
  `raw_stedi_json` longtext,
  `eob_source` enum('carrier_official','stedi_generated') DEFAULT NULL,
  `eob_local_path` varchar(500) DEFAULT NULL,
  `eob_sftp_path` varchar(500) DEFAULT NULL,
  `received_datetime` datetime DEFAULT CURRENT_TIMESTAMP,
  `file_name` varchar(255) DEFAULT NULL,
  `raw_835_path` varchar(500) DEFAULT NULL,
  `payer_name` varchar(100) DEFAULT NULL,
  `payer_id_code` varchar(50) DEFAULT NULL,
  `payer_tax_id` varchar(20) NOT NULL,
  `payee_name` varchar(100) DEFAULT NULL,
  `payee_npi` varchar(20) DEFAULT NULL,
  `check_number` varchar(50) NOT NULL,
  `check_date` date NOT NULL,
  `bank_deposit_date` date DEFAULT NULL,
  `no_deposit_expected` tinyint(1) NOT NULL DEFAULT '0',
  `check_amount` decimal(10,2) NOT NULL,
  `payment_method` varchar(20) DEFAULT NULL,
  `payment_method_description` varchar(50) DEFAULT NULL,
  `account_number_last4` varchar(4) DEFAULT NULL,
  `is_credit` tinyint(1) DEFAULT '1',
  `total_claim_count` int DEFAULT '0',
  `status` enum('uploaded','pending_review','ready_to_post','posting','posted','partially_posted','awaiting_finalization','error') DEFAULT 'uploaded',
  `posted_datetime` datetime DEFAULT NULL,
  `posted_by_user_id` int DEFAULT NULL,
  `od_claimpayment_num` int DEFAULT NULL,
  `notes` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `bank_deposit_linked_at` datetime DEFAULT NULL,
  `bank_deposit_linked_by` varchar(100) DEFAULT NULL,
  `bank_deposit_link_method` enum('auto_teller','manual_entry') DEFAULT NULL,
  PRIMARY KEY (`era_id`),
  KEY `idx_era_status` (`status`),
  KEY `idx_era_check_date` (`check_date`),
  KEY `idx_era_check_number` (`check_number`),
  KEY `idx_era_payer` (`payer_name`,`payer_tax_id`),
  KEY `idx_era_duplicate` (`check_number`,`payer_tax_id`,`check_amount`),
  KEY `idx_era_payments_stedi_txn` (`stedi_transaction_id`),
  KEY `idx_era_payments_date_status` (`check_date`,`status`),
  KEY `idx_era_payments_received` (`received_datetime`),
  KEY `idx_era_payments_posted` (`posted_datetime`),
  KEY `idx_era_payments_no_deposit_expected` (`no_deposit_expected`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `era_claims` (
  `era_claim_id` int NOT NULL AUTO_INCREMENT,
  `era_id` int NOT NULL,
  `claim_identifier` varchar(50) DEFAULT NULL,
  `patient_first_name` varchar(50) DEFAULT NULL,
  `patient_last_name` varchar(50) DEFAULT NULL,
  `subscriber_first_name` varchar(50) DEFAULT NULL,
  `subscriber_last_name` varchar(50) DEFAULT NULL,
  `subscriber_id` varchar(50) DEFAULT NULL,
  `claim_status_code` varchar(5) DEFAULT NULL,
  `claim_status_description` varchar(100) DEFAULT NULL,
  `payer_control_number` varchar(50) DEFAULT NULL,
  `rendering_provider_npi` varchar(20) DEFAULT NULL,
  `date_service_start` date DEFAULT NULL,
  `date_service_end` date DEFAULT NULL,
  `is_reversal` tinyint(1) DEFAULT '0',
  `is_preauth` tinyint(1) DEFAULT '0',
  `is_split_claim` tinyint(1) DEFAULT '0',
  `total_charge_amount` decimal(10,2) DEFAULT NULL,
  `paid_amount` decimal(10,2) DEFAULT NULL,
  `patient_responsibility_amount` decimal(10,2) DEFAULT NULL,
  `writeoff_total` decimal(10,2) DEFAULT NULL,
  `deductible_total` decimal(10,2) DEFAULT NULL,
  `patient_portion_total` decimal(10,2) DEFAULT NULL,
  `reason_under_paid` varchar(400) DEFAULT NULL,
  `od_claim_num` int DEFAULT NULL,
  `patnum` bigint DEFAULT NULL,
  `od_claim_type` varchar(10) DEFAULT NULL,
  `od_claim_status` varchar(5) DEFAULT NULL,
  `match_status` enum('unmatched','matched','ambiguous') NOT NULL DEFAULT 'unmatched',
  `match_method` varchar(50) DEFAULT NULL,
  `match_confidence` varchar(20) DEFAULT NULL,
  `claim_review_status` enum('ready','edited','excluded','unmatched','posted','manually_posted','failed','manual_review','post_in_od','manually_posted_in_od','needs_attention') DEFAULT 'ready',
  `is_excluded` tinyint(1) DEFAULT '0',
  `exclusion_reason` enum('cob_reprocess','appeal','wait_for_patient_info','post_in_od_manual','duplicate','other') DEFAULT NULL,
  `exclusion_note` varchar(1000) DEFAULT NULL,
  `review_flags` json DEFAULT NULL,
  `posted_to_od` tinyint(1) DEFAULT '0',
  `od_claimpayment_num` int DEFAULT NULL,
  `posting_error` text,
  `has_name_mismatch` tinyint(1) DEFAULT '0',
  `name_mismatch_details` json DEFAULT NULL,
  `name_mismatch_resolved` tinyint(1) DEFAULT '0',
  `has_secondary` tinyint(1) DEFAULT '0',
  `secondary_claim_num` bigint DEFAULT NULL,
  `secondary_status` enum('hold','sent','received','timeout') DEFAULT 'hold',
  `days_since_primary_posted` int DEFAULT '0',
  `primary_in_network` tinyint(1) DEFAULT NULL,
  `secondary_in_network` tinyint(1) DEFAULT NULL,
  `fee_ceiling` decimal(10,2) DEFAULT NULL,
  `writeoff_pending` tinyint(1) DEFAULT '0',
  `writeoff_amount_calculated` decimal(10,2) DEFAULT NULL,
  `writeoff_posted_on_claim` bigint DEFAULT NULL,
  `writeoff_posted_date` datetime DEFAULT NULL,
  `has_type_mismatch` tinyint(1) DEFAULT '0',
  `type_mismatch_resolved` tinyint(1) DEFAULT '0',
  `mismatch_auto_resolved` tinyint(1) NOT NULL DEFAULT '0',
  `secondary_awaiting_primary` tinyint(1) NOT NULL DEFAULT '0',
  `cross_code_case` char(1) DEFAULT NULL,
  `case_b_allocation` json DEFAULT NULL,
  `mismatch_resolved_as` varchar(20) DEFAULT NULL,
  `primary_paid_total` decimal(10,2) DEFAULT NULL,
  `type_mismatch_details` json DEFAULT NULL,
  `subscriber_id_era` varchar(50) DEFAULT NULL,
  `subscriber_id_od` varchar(50) DEFAULT NULL,
  `unmatched_service_line_count` int DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`era_claim_id`),
  KEY `idx_eraclaim_era_id` (`era_id`),
  KEY `idx_eraclaim_claim_identifier` (`claim_identifier`),
  KEY `idx_eraclaim_od_claim_num` (`od_claim_num`),
  KEY `idx_eraclaim_match_status` (`match_status`),
  KEY `idx_eraclaim_subscriber_id` (`subscriber_id`),
  KEY `idx_era_claims_match_review` (`match_status`,`claim_review_status`),
  KEY `idx_era_claims_posted_created` (`posted_to_od`,`created_at`),
  KEY `idx_eraclaims_patnum` (`patnum`),
  KEY `idx_era_claims_secondary_awaiting_primary` (`secondary_awaiting_primary`),
  KEY `idx_era_claims_cross_code_case` (`cross_code_case`),
  CONSTRAINT `fk_eraclaim_era` FOREIGN KEY (`era_id`) REFERENCES `era_payments` (`era_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `era_service_lines` (
  `service_line_id` int NOT NULL AUTO_INCREMENT,
  `era_claim_id` int NOT NULL,
  `line_number` int DEFAULT NULL,
  `proc_code_billed` varchar(10) DEFAULT NULL,
  `proc_code_adjudicated` varchar(10) DEFAULT NULL,
  `service_date_start` date DEFAULT NULL,
  `service_date_end` date DEFAULT NULL,
  `units` int DEFAULT '1',
  `charge_amount` decimal(10,2) DEFAULT NULL,
  `proc_fee` decimal(10,2) DEFAULT NULL,
  `paid_amount` decimal(10,2) DEFAULT NULL,
  `deductible` decimal(10,2) DEFAULT NULL,
  `writeoff` decimal(10,2) DEFAULT NULL,
  `patient_portion` decimal(10,2) DEFAULT NULL,
  `remark_codes` json DEFAULT NULL,
  `ref_6r_raw` varchar(50) DEFAULT NULL,
  `ref_6r_format` varchar(10) DEFAULT NULL,
  `ref_6r_proc_num` bigint DEFAULT NULL,
  `ref_6r_plan_num` bigint DEFAULT NULL,
  `ref_6r_plan_ordinal` int DEFAULT NULL,
  `od_claimproc_num` int DEFAULT NULL,
  `calc_ins_pay_amt` decimal(10,2) DEFAULT NULL,
  `calc_ded_applied` decimal(10,2) DEFAULT NULL,
  `calc_writeoff` decimal(10,2) DEFAULT NULL,
  `calc_allowed_override` decimal(10,2) DEFAULT NULL,
  `calc_remarks` text,
  `calc_positive_adjustment` decimal(10,2) DEFAULT NULL,
  `allowed_amount_era` decimal(10,2) DEFAULT NULL,
  `allowed_amount_od` decimal(10,2) DEFAULT NULL,
  `fee_schedule_amount` decimal(10,2) DEFAULT NULL,
  `contracted_fee` decimal(10,2) DEFAULT NULL,
  `allowed_source` varchar(20) DEFAULT NULL,
  `allowed_variance` decimal(10,2) DEFAULT NULL,
  `preauth_estimate` decimal(10,2) DEFAULT NULL,
  `should_post_writeoff` tinyint(1) DEFAULT NULL,
  `writeoff_decision_reason` varchar(100) DEFAULT NULL,
  `writeoff_decision_confidence` enum('high','medium','low') DEFAULT NULL,
  `requires_writeoff_review` tinyint(1) DEFAULT '0',
  `deferred_to_secondary` tinyint(1) DEFAULT '0',
  `triggered_rules` json DEFAULT NULL,
  `has_blocking_flag` tinyint(1) DEFAULT '0',
  `has_warning_flag` tinyint(1) DEFAULT '0',
  `posting_error` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `is_excluded` tinyint(1) NOT NULL DEFAULT '0',
  `excluded_reason` varchar(500) DEFAULT NULL,
  `excluded_by_user_id` int DEFAULT NULL,
  `excluded_at` datetime DEFAULT NULL,
  PRIMARY KEY (`service_line_id`),
  KEY `idx_erasvc_era_claim_id` (`era_claim_id`),
  KEY `idx_erasvc_ref6r_proc_num` (`ref_6r_proc_num`),
  KEY `idx_erasvc_od_claimproc_num` (`od_claimproc_num`),
  KEY `idx_era_service_lines_is_excluded` (`era_claim_id`,`is_excluded`),
  CONSTRAINT `fk_erasvc_eraclaim` FOREIGN KEY (`era_claim_id`) REFERENCES `era_claims` (`era_claim_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `era_adjustments` (
  `adjustment_id` int NOT NULL AUTO_INCREMENT,
  `era_claim_id` int NOT NULL,
  `era_service_line_id` int DEFAULT NULL,
  `group_code` varchar(5) DEFAULT NULL,
  `reason_code` varchar(10) DEFAULT NULL,
  `reason_description` varchar(255) DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `is_deductible` tinyint(1) DEFAULT '0',
  `reclassified_as` varchar(5) DEFAULT NULL,
  `acknowledged` tinyint(1) DEFAULT '0',
  `acknowledged_by` varchar(100) DEFAULT NULL,
  `acknowledged_at` timestamp NULL DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`adjustment_id`),
  KEY `idx_eraadj_era_claim_id` (`era_claim_id`),
  KEY `idx_eraadj_service_line_id` (`era_service_line_id`),
  KEY `idx_eraadj_group_code` (`group_code`),
  KEY `idx_eraadj_reason_code` (`reason_code`),
  CONSTRAINT `fk_eraadj_eraclaim` FOREIGN KEY (`era_claim_id`) REFERENCES `era_claims` (`era_claim_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_eraadj_erasvc` FOREIGN KEY (`era_service_line_id`) REFERENCES `era_service_lines` (`service_line_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `era_audit_events` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `era_id` int DEFAULT NULL,
  `era_claim_id` int DEFAULT NULL,
  `event_type` varchar(100) NOT NULL,
  `event_payload` json DEFAULT NULL,
  `actor_user_id` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_era_audit_era_id` (`era_id`),
  KEY `idx_era_audit_event_type` (`event_type`),
  KEY `idx_era_audit_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `era_match_log` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `era_claim_id` int NOT NULL,
  `action` enum('auto_match','auto_rematch','manual_match','manual_detach') NOT NULL,
  `match_method` varchar(50) DEFAULT NULL,
  `match_confidence` varchar(20) DEFAULT NULL,
  `od_claim_num` int DEFAULT NULL,
  `candidates_considered` int DEFAULT '0',
  `match_details` json DEFAULT NULL,
  `performed_by` varchar(50) DEFAULT 'system',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`log_id`),
  KEY `idx_eramatch_era_claim_id` (`era_claim_id`),
  KEY `idx_eramatch_action` (`action`),
  CONSTRAINT `fk_eramatch_eraclaim` FOREIGN KEY (`era_claim_id`) REFERENCES `era_claims` (`era_claim_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `era_posting_overrides` (
  `id` int NOT NULL AUTO_INCREMENT,
  `era_claim_id` int NOT NULL,
  `era_service_line_id` int DEFAULT NULL,
  `field_name` varchar(50) NOT NULL,
  `calculated_value` decimal(10,2) DEFAULT NULL,
  `overridden_value` decimal(10,2) DEFAULT NULL,
  `override_reason` text,
  `overridden_by` varchar(100) DEFAULT NULL,
  `overridden_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `applied_to_od` tinyint(1) DEFAULT '0',
  `applied_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_override_era_claim` (`era_claim_id`),
  KEY `idx_override_service_line` (`era_service_line_id`),
  CONSTRAINT `fk_override_eraclaim` FOREIGN KEY (`era_claim_id`) REFERENCES `era_claims` (`era_claim_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_override_erasvc` FOREIGN KEY (`era_service_line_id`) REFERENCES `era_service_lines` (`service_line_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `era_provider_adjustments` (
  `provider_adj_id` int NOT NULL AUTO_INCREMENT,
  `era_id` int NOT NULL,
  `npi` varchar(20) DEFAULT NULL,
  `fiscal_period_date` date DEFAULT NULL,
  `reason_code` varchar(10) DEFAULT NULL,
  `reason_description` varchar(255) DEFAULT NULL,
  `reference_id` varchar(50) DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`provider_adj_id`),
  KEY `idx_eraprovadj_era_id` (`era_id`),
  CONSTRAINT `fk_eraprovadj_era` FOREIGN KEY (`era_id`) REFERENCES `era_payments` (`era_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `adjustment_anomalies` (
  `id` int NOT NULL AUTO_INCREMENT,
  `era_adjustment_id` int NOT NULL,
  `era_claim_id` int NOT NULL,
  `severity` enum('info','warning','critical') NOT NULL,
  `anomaly_type` varchar(50) NOT NULL,
  `reason` text NOT NULL,
  `suggested_action` text,
  `detected_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `acknowledged` tinyint(1) DEFAULT '0',
  `acknowledged_by` varchar(100) DEFAULT NULL,
  `acknowledged_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_anomaly_era_claim` (`era_claim_id`),
  KEY `idx_anomaly_era_adj` (`era_adjustment_id`),
  KEY `idx_anomaly_severity` (`severity`),
  KEY `idx_anomaly_acknowledged` (`acknowledged`),
  CONSTRAINT `fk_anomaly_eraadj` FOREIGN KEY (`era_adjustment_id`) REFERENCES `era_adjustments` (`adjustment_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_anomaly_eraclaim` FOREIGN KEY (`era_claim_id`) REFERENCES `era_claims` (`era_claim_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `adjustment_patterns` (
  `id` int NOT NULL AUTO_INCREMENT,
  `payer_id` int NOT NULL,
  `group_code` varchar(3) NOT NULL,
  `reason_code` varchar(10) NOT NULL,
  `occurrences` int DEFAULT '1',
  `total_amount` decimal(10,2) DEFAULT '0.00',
  `avg_amount` decimal(10,2) DEFAULT '0.00',
  `first_seen` datetime DEFAULT NULL,
  `last_seen` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_pattern_unique` (`payer_id`,`group_code`,`reason_code`),
  KEY `idx_pattern_payer_codes` (`payer_id`,`group_code`,`reason_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `carrier_rules` (
  `carrier_rule_id` int NOT NULL AUTO_INCREMENT,
  `payer_id` varchar(50) NOT NULL,
  `rule_type` enum('CAS_REMAP','WRITEOFF_OVERRIDE','AUTO_APPROVE','CUSTOM') NOT NULL,
  `condition_json` json NOT NULL,
  `action_json` json NOT NULL,
  `description` text,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`carrier_rule_id`),
  KEY `idx_carrier_rules_payer` (`payer_id`),
  KEY `idx_carrier_rules_type` (`rule_type`),
  KEY `idx_carrier_rules_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `cob_calculation_log` (
  `log_id` int NOT NULL AUTO_INCREMENT,
  `era_claim_id` int NOT NULL,
  `claim_num` bigint NOT NULL,
  `patient_num` bigint NOT NULL,
  `proc_fee` decimal(10,2) DEFAULT NULL,
  `primary_allowed` decimal(10,2) DEFAULT NULL,
  `primary_paid` decimal(10,2) DEFAULT NULL,
  `primary_in_network` tinyint(1) DEFAULT NULL,
  `secondary_allowed` decimal(10,2) DEFAULT NULL,
  `secondary_paid` decimal(10,2) DEFAULT NULL,
  `secondary_in_network` tinyint(1) DEFAULT NULL,
  `fee_ceiling` decimal(10,2) DEFAULT NULL,
  `total_writeoff` decimal(10,2) DEFAULT NULL,
  `patient_balance` decimal(10,2) DEFAULT NULL,
  `calculation_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `posted_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`log_id`),
  KEY `idx_coblog_era_claim` (`era_claim_id`),
  KEY `idx_coblog_claim_num` (`claim_num`),
  KEY `idx_coblog_patient_num` (`patient_num`),
  CONSTRAINT `fk_coblog_eraclaim` FOREIGN KEY (`era_claim_id`) REFERENCES `era_claims` (`era_claim_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `custom_code_descriptions` (
  `code_desc_id` int NOT NULL AUTO_INCREMENT,
  `code_type` enum('CARC','RARC') NOT NULL,
  `code` varchar(10) NOT NULL,
  `payer_id` varchar(50) DEFAULT NULL,
  `description` varchar(500) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`code_desc_id`),
  UNIQUE KEY `idx_custom_code_unique` (`code_type`,`code`,`payer_id`),
  KEY `idx_custom_code_type` (`code_type`,`code`),
  KEY `idx_custom_code_payer` (`payer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `fee_schedule_settings` (
  `fee_sched_num` bigint NOT NULL,
  `is_in_network` tinyint(1) DEFAULT '0',
  `network_name` varchar(100) DEFAULT NULL,
  `contract_type` enum('ppo','dhmo','indemnity','medicaid','medicare') DEFAULT NULL,
  `effective_date` date DEFAULT NULL,
  `termination_date` date DEFAULT NULL,
  `notes` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_by` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`fee_sched_num`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `follow_up_actions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `era_claim_id` int NOT NULL,
  `od_claim_num` bigint DEFAULT NULL,
  `patient_name` varchar(200) DEFAULT NULL,
  `payer_name` varchar(200) DEFAULT NULL,
  `action_type` enum('appeal','resubmit','underpayment','reversal','statement','credit_balance','review','denial_closed') NOT NULL,
  `reason` text NOT NULL,
  `trigger_details` json DEFAULT NULL,
  `status` enum('open','in_progress','submitted','completed','dismissed') DEFAULT 'open',
  `assigned_to` varchar(100) DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `resolution` text,
  `resolved_at` datetime DEFAULT NULL,
  `resolved_by` varchar(100) DEFAULT NULL,
  `notes` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_followup_era_claim` (`era_claim_id`),
  KEY `idx_followup_status` (`status`),
  KEY `idx_followup_action_type` (`action_type`),
  KEY `idx_followup_due_date` (`due_date`),
  KEY `idx_followup_assigned_to` (`assigned_to`),
  KEY `idx_followup_od_claim_num` (`od_claim_num`),
  CONSTRAINT `fk_followup_eraclaim` FOREIGN KEY (`era_claim_id`) REFERENCES `era_claims` (`era_claim_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `posting_results` (
  `posting_result_id` int NOT NULL AUTO_INCREMENT,
  `era_id` int NOT NULL,
  `era_claim_id` int NOT NULL,
  `action` enum('update_claimproc','update_claim','create_claimpayment') NOT NULL,
  `od_entity_id` int DEFAULT NULL,
  `request_payload` json DEFAULT NULL,
  `response_payload` json DEFAULT NULL,
  `success` tinyint(1) NOT NULL DEFAULT '0',
  `error_message` text,
  `performed_by` varchar(50) DEFAULT 'system',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`posting_result_id`),
  KEY `idx_pr_era_id` (`era_id`),
  KEY `idx_pr_era_claim_id` (`era_claim_id`),
  KEY `idx_pr_action` (`action`),
  CONSTRAINT `fk_pr_era` FOREIGN KEY (`era_id`) REFERENCES `era_payments` (`era_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_pr_eraclaim` FOREIGN KEY (`era_claim_id`) REFERENCES `era_claims` (`era_claim_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `posting_errors` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `posting_result_id` bigint NOT NULL,
  `era_claim_id` bigint DEFAULT NULL,
  `era_service_line_id` bigint DEFAULT NULL,
  `od_claim_num` bigint DEFAULT NULL,
  `od_claimproc_num` bigint DEFAULT NULL,
  `error_type` enum('network','validation','business_rule','rollback','unknown') NOT NULL,
  `error_message` text NOT NULL,
  `api_endpoint` varchar(255) DEFAULT NULL,
  `api_response` text,
  `retry_count` int DEFAULT '0',
  `recoverable` tinyint(1) DEFAULT '1',
  `resolved_at` datetime DEFAULT NULL,
  `resolution_method` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_posterr_posting_result` (`posting_result_id`),
  KEY `idx_posterr_era_claim` (`era_claim_id`),
  KEY `idx_posterr_service_line` (`era_service_line_id`),
  KEY `idx_posterr_recoverable` (`recoverable`,`resolved_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `practice_rule_settings` (
  `setting_key` varchar(100) NOT NULL,
  `setting_value` varchar(500) NOT NULL DEFAULT '',
  `setting_type` enum('boolean','number','string') NOT NULL DEFAULT 'string',
  `category` varchar(50) NOT NULL DEFAULT 'rules',
  `description` text,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`setting_key`),
  KEY `idx_practice_rule_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------------------------------------------------------------
-- Section 6: Banking, deposits, reconciliation, CC funding, Sunbit, CareCredit
-- ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `teller_bank_accounts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `teller_account_id` varchar(100) NOT NULL,
  `teller_enrollment_id` varchar(100) DEFAULT NULL,
  `teller_access_token` varchar(255) DEFAULT NULL,
  `teller_institution_name` varchar(255) DEFAULT NULL,
  `account_name` varchar(100) NOT NULL,
  `account_number_last4` varchar(4) DEFAULT NULL,
  `account_type` varchar(50) DEFAULT NULL,
  `account_subtype` varchar(50) DEFAULT NULL,
  `currency` varchar(10) DEFAULT 'USD',
  `status` enum('active','disconnected','inactive') DEFAULT 'active',
  `is_primary` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `balance_available` decimal(12,2) DEFAULT NULL,
  `balance_ledger` decimal(12,2) DEFAULT NULL,
  `balance_updated_at` datetime DEFAULT NULL,
  `last_poll_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_teller_account_id` (`teller_account_id`),
  KEY `idx_teller_enrollment_id` (`teller_enrollment_id`),
  KEY `idx_status` (`status`),
  KEY `idx_is_primary` (`is_primary`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `bank_accounts` (
  `bank_account_id` int NOT NULL AUTO_INCREMENT,
  `account_name` varchar(100) NOT NULL,
  `account_number_last4` varchar(4) DEFAULT NULL,
  `routing_number` varchar(20) DEFAULT NULL,
  `teller_account_id` varchar(100) DEFAULT NULL,
  `teller_enrollment_id` varchar(100) DEFAULT NULL,
  `teller_access_token` varchar(255) DEFAULT NULL,
  `teller_institution_name` varchar(255) DEFAULT NULL,
  `account_type` varchar(50) DEFAULT NULL,
  `account_subtype` varchar(50) DEFAULT NULL,
  `currency` varchar(10) DEFAULT 'USD',
  `status` enum('active','disconnected','inactive') DEFAULT 'active',
  `is_primary` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`bank_account_id`),
  UNIQUE KEY `uk_teller_account_id` (`teller_account_id`),
  KEY `idx_teller_enrollment_id` (`teller_enrollment_id`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `bank_transactions` (
  `transaction_id` int NOT NULL AUTO_INCREMENT,
  `bank_account_id` int DEFAULT NULL,
  `teller_transaction_id` varchar(100) DEFAULT NULL,
  `post_date` date NOT NULL,
  `transaction_type` enum('insurance','credit_card','financing','check','transfer','other') NOT NULL DEFAULT 'other',
  `category_code` varchar(10) DEFAULT NULL,
  `counterparty_name` varchar(200) DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `description` text,
  `check_number` varchar(50) DEFAULT NULL,
  `payer_tax_id` varchar(20) DEFAULT NULL,
  `matched_era_id` int DEFAULT NULL,
  `match_method` enum('check_number','amount_date','manual') DEFAULT NULL,
  `match_confidence` enum('high','medium','low') DEFAULT NULL,
  `teller_status` varchar(20) DEFAULT NULL,
  `teller_running_balance` decimal(12,2) DEFAULT NULL,
  `teller_category` varchar(100) DEFAULT NULL,
  `teller_counterparty_type` varchar(50) DEFAULT NULL,
  `manual_post_claimed` tinyint(1) DEFAULT '0',
  `is_late_entry` tinyint(1) DEFAULT '0',
  `late_entry_detected_at` datetime DEFAULT NULL,
  `claimed_at` datetime DEFAULT NULL,
  `claimed_by_user_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `teller_bank_account_id` int DEFAULT NULL,
  PRIMARY KEY (`transaction_id`),
  UNIQUE KEY `uk_teller_transaction_id` (`teller_transaction_id`),
  KEY `bank_account_id` (`bank_account_id`),
  KEY `idx_post_date` (`post_date`),
  KEY `idx_transaction_type` (`transaction_type`),
  KEY `idx_check_number` (`check_number`),
  KEY `idx_payer_tax_id` (`payer_tax_id`),
  KEY `idx_matched_era_id` (`matched_era_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_recon_daily` (`post_date`,`teller_bank_account_id`,`transaction_type`,`amount`),
  KEY `fk_bank_txn_teller_acct` (`teller_bank_account_id`),
  CONSTRAINT `fk_bank_txn_teller_acct` FOREIGN KEY (`teller_bank_account_id`) REFERENCES `teller_bank_accounts` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `bank_transactions_archive` (
  `transaction_id` int NOT NULL,
  `bank_account_id` int NOT NULL,
  `teller_bank_account_id` int DEFAULT NULL,
  `teller_transaction_id` varchar(100) DEFAULT NULL,
  `post_date` date NOT NULL,
  `transaction_type` enum('insurance','credit_card','financing','check','transfer','other') NOT NULL DEFAULT 'other',
  `category_code` varchar(10) DEFAULT NULL,
  `counterparty_name` varchar(200) DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `description` text,
  `check_number` varchar(50) DEFAULT NULL,
  `payer_tax_id` varchar(20) DEFAULT NULL,
  `matched_era_id` int DEFAULT NULL,
  `match_method` enum('check_number','amount_date','manual') DEFAULT NULL,
  `match_confidence` enum('high','medium','low') DEFAULT NULL,
  `teller_status` varchar(20) DEFAULT NULL,
  `teller_running_balance` decimal(12,2) DEFAULT NULL,
  `teller_category` varchar(100) DEFAULT NULL,
  `teller_counterparty_type` varchar(50) DEFAULT NULL,
  `manual_post_claimed` tinyint(1) DEFAULT '0',
  `claimed_at` datetime DEFAULT NULL,
  `claimed_by_user_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `archived_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`transaction_id`),
  KEY `idx_post_date` (`post_date`),
  KEY `idx_check_number` (`check_number`),
  KEY `idx_matched_era_id` (`matched_era_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `check_deposit_details` (
  `detail_id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` int NOT NULL,
  `payer_name` varchar(100) DEFAULT NULL,
  `check_number` varchar(50) DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`detail_id`),
  KEY `idx_transaction_id` (`transaction_id`),
  KEY `idx_check_number` (`check_number`),
  CONSTRAINT `fk_check_detail_txn` FOREIGN KEY (`transaction_id`) REFERENCES `bank_transactions` (`transaction_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `check_deposit_details_archive` (
  `detail_id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` int NOT NULL,
  `payer_name` varchar(100) DEFAULT NULL,
  `check_number` varchar(50) DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`detail_id`),
  KEY `idx_transaction_id` (`transaction_id`),
  KEY `idx_check_number` (`check_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `checkeeper_bank_accounts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `account_label` varchar(100) NOT NULL DEFAULT 'Primary Checking',
  `routing_number_encrypted` varchar(512) NOT NULL,
  `account_number_encrypted` varchar(512) NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- [EXCLUDED] CREATE TABLE `od_insurance_payments` — OpenDental claimpayment mirror; removed by cleanup.

-- [EXCLUDED] CREATE TABLE `od_patient_payments` — OpenDental payment mirror; removed by cleanup.

CREATE TABLE IF NOT EXISTS `cc_funding_records` (
  `funding_id` varchar(22) NOT NULL,
  `funding_master_id` varchar(22) DEFAULT NULL,
  `funding_date` date DEFAULT NULL,
  `merchid` varchar(16) DEFAULT NULL,
  `net_sales` decimal(12,2) DEFAULT NULL,
  `total_funding` decimal(12,2) DEFAULT NULL,
  `fee` decimal(12,2) DEFAULT NULL,
  `reversal` decimal(12,2) DEFAULT NULL,
  `interchange_fee` decimal(12,2) DEFAULT NULL,
  `service_charge` decimal(12,2) DEFAULT NULL,
  `adjustment` decimal(12,2) DEFAULT NULL,
  `other_adjustment` decimal(12,2) DEFAULT NULL,
  `third_party` decimal(12,2) DEFAULT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `dda_number` varchar(20) DEFAULT NULL,
  `aba_number` varchar(20) DEFAULT NULL,
  `deposit_ach_trace` varchar(20) DEFAULT NULL,
  `deposit_tran_code` varchar(10) DEFAULT NULL,
  `date_added` date DEFAULT NULL,
  `date_changed` date DEFAULT NULL,
  `synced_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`funding_id`),
  KEY `idx_funding_date` (`funding_date`),
  KEY `idx_funding_master_id` (`funding_master_id`),
  KEY `idx_merchid` (`merchid`),
  KEY `idx_cc_fund_date_mid_amt` (`funding_date`,`merchid`,`total_funding`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `cc_funding_txns` (
  `funding_txn_id` varchar(22) NOT NULL,
  `funding_id` varchar(22) NOT NULL,
  `retref` varchar(14) DEFAULT NULL,
  `parent_retref` varchar(20) DEFAULT NULL,
  `amount` decimal(12,2) DEFAULT NULL,
  `card_type` varchar(4) DEFAULT NULL,
  `card_brand` varchar(30) DEFAULT NULL,
  `card_number` varchar(25) DEFAULT NULL,
  `txn_type` varchar(25) DEFAULT NULL,
  `txn_status` varchar(100) DEFAULT NULL,
  `auth_code` varchar(6) DEFAULT NULL,
  `auth_date` varchar(14) DEFAULT NULL,
  `resp_code` varchar(3) DEFAULT NULL,
  `batch_id` varchar(12) DEFAULT NULL,
  `card_proc` varchar(4) DEFAULT NULL,
  `txn_date` varchar(8) DEFAULT NULL,
  `funding_date` date DEFAULT NULL,
  `invoice_number` varchar(100) DEFAULT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `synced_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`funding_txn_id`),
  KEY `idx_funding_id` (`funding_id`),
  KEY `idx_txn_type` (`txn_type`),
  KEY `idx_auth_date` (`auth_date`),
  KEY `idx_retref` (`retref`),
  KEY `idx_parent_retref` (`parent_retref`),
  KEY `idx_txn_funding_date` (`funding_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `cc_funding_adjustments` (
  `funding_adjustment_id` varchar(22) NOT NULL,
  `funding_master_id` varchar(22) DEFAULT NULL,
  `amount` decimal(12,2) DEFAULT NULL,
  `description` varchar(200) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `txn_type` varchar(25) DEFAULT NULL,
  `currency` varchar(3) DEFAULT 'USD',
  `case_number` varchar(30) DEFAULT NULL,
  `merchid` varchar(16) DEFAULT NULL,
  `date_added` date DEFAULT NULL,
  `date_changed` date DEFAULT NULL,
  `funding_date` date DEFAULT NULL,
  `synced_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`funding_adjustment_id`),
  KEY `idx_funding_master_id` (`funding_master_id`),
  KEY `idx_funding_date` (`funding_date`),
  KEY `idx_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `cc_funding_chargebacks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `funding_chargeback_id` varchar(22) NOT NULL,
  `funding_master_id` varchar(22) DEFAULT NULL,
  `amount` decimal(12,2) DEFAULT NULL,
  `transaction_amount` decimal(12,2) DEFAULT NULL,
  `reason_code` varchar(10) DEFAULT NULL,
  `reason_description` varchar(200) DEFAULT NULL,
  `chargeback_date` date DEFAULT NULL,
  `transaction_date` date DEFAULT NULL,
  `deposit_date` date DEFAULT NULL,
  `card_number` varchar(25) DEFAULT NULL,
  `retref` varchar(14) DEFAULT NULL,
  `auth_code` varchar(6) DEFAULT NULL,
  `case_number` varchar(30) DEFAULT NULL,
  `sequence_number` varchar(30) DEFAULT NULL,
  `acquirer_reference_number` varchar(30) DEFAULT NULL,
  `invoice_number` varchar(100) DEFAULT NULL,
  `merchid` varchar(16) DEFAULT NULL,
  `date_added` date DEFAULT NULL,
  `date_changed` date DEFAULT NULL,
  `funding_date` date DEFAULT NULL,
  `synced_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_chargeback_dedup` (`funding_chargeback_id`,`funding_master_id`),
  KEY `idx_funding_date` (`funding_date`),
  KEY `idx_chargeback_date` (`chargeback_date`),
  KEY `idx_retref` (`retref`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `carecredit_uploads` (
  `id` int NOT NULL AUTO_INCREMENT,
  `file_name` varchar(255) NOT NULL,
  `report_type` enum('daily','monthly') NOT NULL,
  `run_date` date DEFAULT NULL,
  `date_range_start` date DEFAULT NULL,
  `date_range_end` date DEFAULT NULL,
  `merchant_number` varchar(20) DEFAULT NULL,
  `merchant_name` varchar(200) DEFAULT NULL,
  `row_count` int NOT NULL DEFAULT '0',
  `total_tran_amt_cents` bigint NOT NULL DEFAULT '0',
  `total_disc_amt_cents` bigint NOT NULL DEFAULT '0',
  `total_net_funding_cents` bigint NOT NULL DEFAULT '0',
  `uploaded_by` int DEFAULT NULL,
  `uploaded_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_report_type` (`report_type`),
  KEY `idx_date_range` (`date_range_start`,`date_range_end`),
  KEY `idx_uploaded_at` (`uploaded_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `carecredit_txns` (
  `id` int NOT NULL AUTO_INCREMENT,
  `upload_id` int NOT NULL,
  `merchant_nbr` varchar(20) NOT NULL,
  `tran_type` varchar(20) NOT NULL,
  `tran_date` date NOT NULL,
  `post_date` date DEFAULT NULL,
  `card_number_masked` varchar(20) DEFAULT NULL,
  `patient_last_name` varchar(100) DEFAULT NULL,
  `patient_first_name` varchar(100) DEFAULT NULL,
  `auth_code` varchar(20) DEFAULT NULL,
  `tran_amt_cents` bigint NOT NULL,
  `disc_amt_cents` bigint NOT NULL DEFAULT '0',
  `disc_rate` decimal(8,4) DEFAULT NULL,
  `net_funding_cents` bigint NOT NULL,
  `card_type_desc` varchar(50) DEFAULT NULL,
  `tran_desc` varchar(200) DEFAULT NULL,
  `promo_id` varchar(20) DEFAULT NULL,
  `promo_desc` varchar(200) DEFAULT NULL,
  `report_type` enum('daily','monthly') NOT NULL,
  `dedup_hash` varchar(64) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_dedup_hash` (`dedup_hash`),
  KEY `idx_upload_id` (`upload_id`),
  KEY `idx_tran_date` (`tran_date`),
  KEY `idx_post_date` (`post_date`),
  KEY `idx_tran_type` (`tran_type`),
  KEY `idx_report_type` (`report_type`),
  CONSTRAINT `fk_carecredit_txn_upload` FOREIGN KEY (`upload_id`) REFERENCES `carecredit_uploads` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `sunbit_uploads` (
  `id` int NOT NULL AUTO_INCREMENT,
  `file_name` varchar(255) NOT NULL,
  `date_range_start` date DEFAULT NULL,
  `date_range_end` date DEFAULT NULL,
  `row_count` int NOT NULL DEFAULT '0',
  `total_treatment_cents` bigint NOT NULL DEFAULT '0',
  `total_fee_cents` bigint NOT NULL DEFAULT '0',
  `total_adjusted_cents` bigint NOT NULL DEFAULT '0',
  `total_paid_cents` bigint NOT NULL DEFAULT '0',
  `avg_fee_rate` decimal(8,4) DEFAULT NULL,
  `uploaded_by` int DEFAULT NULL,
  `uploaded_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_uploaded_at` (`uploaded_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `sunbit_txns` (
  `id` int NOT NULL AUTO_INCREMENT,
  `upload_id` int NOT NULL,
  `activity_date` date NOT NULL,
  `team_member` varchar(100) DEFAULT NULL,
  `purchase_number` varchar(20) NOT NULL,
  `ref_chart_number` varchar(20) DEFAULT NULL,
  `treatment_amt_cents` bigint NOT NULL,
  `fee_rate` decimal(8,4) DEFAULT NULL,
  `fee_amt_cents` bigint NOT NULL DEFAULT '0',
  `adjusted_cents` bigint NOT NULL DEFAULT '0',
  `paid_to_merchant_cents` bigint NOT NULL,
  `activity_type` varchar(50) NOT NULL DEFAULT 'Purchase',
  `source_of_origin` varchar(100) DEFAULT NULL,
  `dedup_hash` varchar(64) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_dedup_hash` (`dedup_hash`),
  KEY `idx_upload_id` (`upload_id`),
  KEY `idx_activity_date` (`activity_date`),
  KEY `idx_purchase_number` (`purchase_number`),
  KEY `idx_ref_chart_number` (`ref_chart_number`),
  CONSTRAINT `fk_sunbit_txn_upload` FOREIGN KEY (`upload_id`) REFERENCES `sunbit_uploads` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `remote_deposits` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bank_transaction_id` int NOT NULL,
  `deposit_date` date NOT NULL,
  `type` enum('ins','pat','other') NOT NULL,
  `account_number` varchar(50) DEFAULT NULL,
  `check_number` varchar(50) DEFAULT NULL,
  `routing_number` varchar(50) DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `tracking_number` varchar(100) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `account_name` varchar(255) DEFAULT NULL,
  `note` text,
  `match_status` enum('unmatched','matched','date_mismatch','excluded') NOT NULL DEFAULT 'unmatched',
  `od_claimpayment_id` int DEFAULT NULL,
  `od_payment_id` int DEFAULT NULL,
  `matched_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_remote_dep_txn_check` (`bank_transaction_id`,`check_number`),
  KEY `idx_bank_txn` (`bank_transaction_id`),
  KEY `idx_deposit_date` (`deposit_date`),
  KEY `idx_check_number` (`check_number`),
  KEY `idx_type` (`type`),
  KEY `idx_match_status` (`match_status`),
  CONSTRAINT `fk_remote_dep_bank_txn` FOREIGN KEY (`bank_transaction_id`) REFERENCES `bank_transactions` (`transaction_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `remote_deposit_insurances` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `deposit_date` date NOT NULL,
  `account_number` varchar(50) DEFAULT NULL,
  `serial` varchar(100) NOT NULL,
  `routing_number` varchar(50) DEFAULT NULL,
  `amount` decimal(15,2) NOT NULL,
  `tracking_number` varchar(100) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `account_name` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `remote_deposit_patients` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `deposit_date` date NOT NULL,
  `account_number` varchar(50) DEFAULT NULL,
  `serial` varchar(100) NOT NULL,
  `routing_number` varchar(50) DEFAULT NULL,
  `amount` decimal(15,2) NOT NULL,
  `tracking_number` varchar(100) DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `account_name` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `recon_links` (
  `link_id` int NOT NULL AUTO_INCREMENT,
  `bank_transaction_id` int DEFAULT NULL,
  `check_detail_id` int DEFAULT NULL,
  `remote_deposit_id` int DEFAULT NULL,
  `od_claimpayment_id` int DEFAULT NULL,
  `od_paynum` int DEFAULT NULL,
  `cc_funding_txn_id` varchar(22) DEFAULT NULL,
  `carecredit_txn_id` int DEFAULT NULL,
  `cc_funding_id` varchar(22) DEFAULT NULL,
  `sunbit_txn_id` int DEFAULT NULL,
  `matched_amount` decimal(10,2) NOT NULL,
  `match_type` enum('auto_check_number','auto_check_number_date_mismatch','auto_amount','auto_amount_date_mismatch','auto_cc_batch','auto_cc_monthly_fee','manual') NOT NULL,
  `match_confidence` decimal(3,2) DEFAULT NULL,
  `matched_by_user_id` int DEFAULT NULL,
  `note` text,
  `matched_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`link_id`),
  UNIQUE KEY `uk_od_claimpayment` (`od_claimpayment_id`),
  UNIQUE KEY `uk_od_paynum` (`od_paynum`),
  UNIQUE KEY `idx_cc_funding_txn` (`cc_funding_txn_id`),
  UNIQUE KEY `idx_carecredit_txn` (`carecredit_txn_id`),
  UNIQUE KEY `idx_sunbit_txn` (`sunbit_txn_id`),
  UNIQUE KEY `idx_cc_funding_batch` (`cc_funding_id`),
  KEY `idx_bank_transaction` (`bank_transaction_id`),
  KEY `idx_check_detail` (`check_detail_id`),
  KEY `idx_remote_deposit` (`remote_deposit_id`),
  KEY `idx_recon_links_bank_txn` (`bank_transaction_id`),
  KEY `idx_recon_links_check_detail` (`check_detail_id`),
  CONSTRAINT `fk_recon_bank_txn` FOREIGN KEY (`bank_transaction_id`) REFERENCES `bank_transactions` (`transaction_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_recon_check_detail` FOREIGN KEY (`check_detail_id`) REFERENCES `check_deposit_details` (`detail_id`) ON DELETE CASCADE,
  CONSTRAINT `fk_recon_links_sunbit_txn` FOREIGN KEY (`sunbit_txn_id`) REFERENCES `sunbit_txns` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `recon_links_archive` (
  `link_id` int NOT NULL AUTO_INCREMENT,
  `bank_transaction_id` int DEFAULT NULL,
  `check_detail_id` int DEFAULT NULL,
  `remote_deposit_id` int DEFAULT NULL,
  `od_claimpayment_id` int NOT NULL,
  `matched_amount` decimal(10,2) NOT NULL,
  `match_type` enum('auto_check_number','auto_amount','manual') NOT NULL,
  `match_confidence` decimal(3,2) DEFAULT NULL,
  `matched_by_user_id` int DEFAULT NULL,
  `matched_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`link_id`),
  UNIQUE KEY `uk_od_claimpayment` (`od_claimpayment_id`),
  KEY `idx_bank_transaction` (`bank_transaction_id`),
  KEY `idx_check_detail` (`check_detail_id`),
  KEY `idx_remote_deposit` (`remote_deposit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `recon_exceptions` (
  `exception_id` int NOT NULL AUTO_INCREMENT,
  `bank_transaction_id` int DEFAULT NULL,
  `check_detail_id` int DEFAULT NULL,
  `od_claimpayment_id` int DEFAULT NULL,
  `exception_type` varchar(50) NOT NULL DEFAULT 'amount_mismatch',
  `bank_amount` decimal(10,2) DEFAULT NULL,
  `od_amount` decimal(10,2) DEFAULT NULL,
  `check_number` varchar(50) DEFAULT NULL,
  `reason` text,
  `resolved` tinyint(1) DEFAULT '0',
  `resolved_by_user_id` int DEFAULT NULL,
  `resolved_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`exception_id`),
  UNIQUE KEY `uk_exception_bank` (`bank_transaction_id`,`od_claimpayment_id`,`exception_type`),
  UNIQUE KEY `uk_exception_detail` (`check_detail_id`,`od_claimpayment_id`,`exception_type`),
  KEY `idx_bank_transaction` (`bank_transaction_id`),
  KEY `idx_resolved` (`resolved`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_exceptions_unresolved` (`resolved`,`exception_type`,`bank_transaction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `recon_exceptions_archive` (
  `exception_id` int NOT NULL AUTO_INCREMENT,
  `bank_transaction_id` int DEFAULT NULL,
  `check_detail_id` int DEFAULT NULL,
  `od_claimpayment_id` int DEFAULT NULL,
  `exception_type` enum('amount_mismatch') NOT NULL DEFAULT 'amount_mismatch',
  `bank_amount` decimal(10,2) DEFAULT NULL,
  `od_amount` decimal(10,2) DEFAULT NULL,
  `check_number` varchar(50) DEFAULT NULL,
  `reason` text NOT NULL,
  `resolved` tinyint(1) DEFAULT '0',
  `resolved_by_user_id` int DEFAULT NULL,
  `resolved_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`exception_id`),
  UNIQUE KEY `uk_exception_bank` (`bank_transaction_id`,`od_claimpayment_id`),
  UNIQUE KEY `uk_exception_detail` (`check_detail_id`,`od_claimpayment_id`),
  KEY `idx_bank_transaction` (`bank_transaction_id`),
  KEY `idx_resolved` (`resolved`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `recon_daily_status` (
  `id` int NOT NULL AUTO_INCREMENT,
  `recon_date` date NOT NULL,
  `teller_account_id` varchar(100) NOT NULL,
  `bank_deposit_count` int DEFAULT '0',
  `bank_deposit_total` decimal(10,2) DEFAULT '0.00',
  `od_payment_count` int DEFAULT '0',
  `od_payment_total` decimal(10,2) DEFAULT '0.00',
  `matched_count` int DEFAULT '0',
  `matched_total` decimal(10,2) DEFAULT '0.00',
  `difference` decimal(10,2) DEFAULT '0.00',
  `status` enum('reconciled','partial','unreconciled','needs_csv','no_activity') NOT NULL DEFAULT 'no_activity',
  `has_exceptions` tinyint(1) DEFAULT '0',
  `reconciled_by` varchar(50) DEFAULT NULL,
  `reconciled_at` datetime DEFAULT NULL,
  `last_calculated_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_date_account` (`recon_date`,`teller_account_id`),
  KEY `idx_status` (`status`),
  KEY `idx_recon_date` (`recon_date`),
  KEY `idx_daily_status_staleness` (`teller_account_id`,`recon_date`,`last_calculated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `recon_daily_snapshots` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `recon_date` date NOT NULL,
  `teller_account_id` varchar(100) NOT NULL,
  `snapshot_type` enum('auto_reconciled','month_close','manual') NOT NULL,
  `bank_deposit_count` int NOT NULL DEFAULT '0',
  `bank_deposit_total` decimal(12,2) NOT NULL DEFAULT '0.00',
  `od_payment_count` int NOT NULL DEFAULT '0',
  `od_payment_total` decimal(12,2) NOT NULL DEFAULT '0.00',
  `matched_count` int NOT NULL DEFAULT '0',
  `matched_total` decimal(12,2) NOT NULL DEFAULT '0.00',
  `difference` decimal(12,2) NOT NULL DEFAULT '0.00',
  `status` varchar(20) NOT NULL,
  `has_exceptions` tinyint(1) NOT NULL DEFAULT '0',
  `snapshot_by` varchar(100) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_snapshot_date` (`recon_date`,`teller_account_id`),
  KEY `idx_snapshot_type` (`snapshot_type`),
  KEY `idx_snapshot_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `recon_monthly_status` (
  `id` int NOT NULL AUTO_INCREMENT,
  `month` varchar(7) NOT NULL,
  `teller_account_id` varchar(100) NOT NULL,
  `status` enum('in_progress','fully_reconciled','closed') NOT NULL DEFAULT 'in_progress',
  `closed_by` varchar(50) DEFAULT NULL,
  `closed_at` datetime DEFAULT NULL,
  `notes` text,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_verified_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_month_account` (`month`,`teller_account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `recon_audit_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `action` varchar(50) NOT NULL,
  `recon_date` date DEFAULT NULL,
  `month` varchar(7) DEFAULT NULL,
  `entity_type` varchar(30) DEFAULT NULL,
  `entity_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `username` varchar(100) DEFAULT NULL,
  `details` json DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_audit_action` (`action`),
  KEY `idx_audit_date` (`recon_date`),
  KEY `idx_audit_month` (`month`),
  KEY `idx_audit_user` (`user_id`),
  KEY `idx_audit_created` (`created_at`),
  KEY `idx_audit_entity` (`entity_type`,`entity_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `stedi_polling_state` (
  `id` int NOT NULL AUTO_INCREMENT,
  `last_poll_datetime` datetime DEFAULT NULL,
  `last_processed_transaction_id` varchar(100) DEFAULT NULL,
  `poll_count` int DEFAULT '0',
  `eras_found` int DEFAULT '0',
  `eras_processed` int DEFAULT '0',
  `eras_skipped_duplicate` int DEFAULT '0',
  `errors_encountered` int DEFAULT '0',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_last_poll` (`last_poll_datetime`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `stedi_poll_state` (
  `id` int NOT NULL AUTO_INCREMENT,
  `last_poll_processed_at` datetime DEFAULT NULL,
  `next_page_token` varchar(2048) DEFAULT NULL,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `stedi_transactions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `transaction_id` varchar(100) NOT NULL,
  `file_execution_id` varchar(100) DEFAULT NULL,
  `status` varchar(20) NOT NULL,
  `direction` varchar(20) DEFAULT 'INBOUND',
  `mode` varchar(20) DEFAULT 'production',
  `processed_at` datetime DEFAULT NULL,
  `payer_name` varchar(255) DEFAULT NULL,
  `check_number` varchar(100) DEFAULT NULL,
  `payment_amount` decimal(12,2) DEFAULT NULL,
  `partnership_id` varchar(100) DEFAULT NULL,
  `partnership_type` varchar(20) DEFAULT NULL,
  `sender_profile_id` varchar(100) DEFAULT NULL,
  `receiver_profile_id` varchar(100) DEFAULT NULL,
  `transaction_set` varchar(10) DEFAULT NULL,
  `x12_release` varchar(30) DEFAULT NULL,
  `raw_json` longtext,
  `pdf_local_path` varchar(500) DEFAULT NULL,
  `edi_835_local_path` varchar(500) DEFAULT NULL,
  `json_local_path` varchar(500) DEFAULT NULL,
  `era_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_stedi_txn_id` (`transaction_id`),
  KEY `idx_stedi_processed_at` (`processed_at`),
  KEY `idx_stedi_payer` (`payer_name`),
  KEY `idx_stedi_era_id` (`era_id`),
  KEY `idx_stedi_check_number` (`check_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ---------------------------------------------------------------
-- Restore session settings
-- ---------------------------------------------------------------
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

-- =====================================================================
-- F1 fix (verification round 2): production-only tables not present in
-- any migration or in latest1.sql. These exist in production via manual
-- CREATE TABLE statements that were never committed to migrations/.
-- Code references in nest-dental-app/src/ depend on them.
-- =====================================================================

SET FOREIGN_KEY_CHECKS = 0;
/*M!999999\- enable the sandbox mode */ 
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `refund_requests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `record_type` enum('patient','insurance') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'patient',
  `patnum` int DEFAULT NULL COMMENT 'Open Dental patient number (NULL for insurance)',
  `insurance_address_book_id` int DEFAULT NULL COMMENT 'FK to insurance_address_book',
  `patient_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `patient_address_line1` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `patient_address_line2` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `patient_city` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `patient_state` varchar(2) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `patient_zip` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `refund_amount` decimal(10,2) NOT NULL,
  `refund_type` enum('check','credit_card') COLLATE utf8mb4_unicode_ci NOT NULL,
  `request_notes` text COLLATE utf8mb4_unicode_ci,
  `manual_check_required` tinyint(1) DEFAULT '0' COMMENT 'Bypass PostGrid, manual check needed',
  `status` enum('pending','approved','check_created','check_pending','credit_card_pending','processing','requires_office_pickup','completed','rejected','failed','void_review') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending' COMMENT 'Refund request status: pending → approved → check_created → processing → completed (plus legacy/edge states)',
  `address_verified` tinyint(1) DEFAULT '0' COMMENT 'User confirmed address',
  `address_verified_at` timestamp NULL DEFAULT NULL,
  `approved_by_user_id` int DEFAULT NULL,
  `approved_at` timestamp NULL DEFAULT NULL,
  `approval_notes` text COLLATE utf8mb4_unicode_ci,
  `rejected_at` timestamp NULL DEFAULT NULL,
  `rejection_notes` text COLLATE utf8mb4_unicode_ci,
  `check_register_id` int DEFAULT NULL COMMENT 'FK to check_register',
  `od_payment_id` int DEFAULT NULL COMMENT 'Open Dental payment record ID',
  `attachment_file_path` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `attachment_filename` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `attachment_content_type` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `attachment_file_size` int DEFAULT NULL,
  `attachment_uploaded_at` timestamp NULL DEFAULT NULL,
  `error_message` text COLLATE utf8mb4_unicode_ci,
  `retry_count` int DEFAULT '0',
  `created_by_user_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `completed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_patnum` (`patnum`),
  KEY `idx_insurance_address` (`insurance_address_book_id`),
  KEY `idx_status` (`status`),
  KEY `idx_record_type` (`record_type`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_check_register` (`check_register_id`),
  KEY `approved_by_user_id` (`approved_by_user_id`),
  KEY `created_by_user_id` (`created_by_user_id`),
  CONSTRAINT `refund_requests_ibfk_1` FOREIGN KEY (`approved_by_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `refund_requests_ibfk_2` FOREIGN KEY (`created_by_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `refund_requests_ibfk_3` FOREIGN KEY (`insurance_address_book_id`) REFERENCES `insurance_address_book` (`id`),
  CONSTRAINT `refund_requests_ibfk_4` FOREIGN KEY (`check_register_id`) REFERENCES `check_register` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Main refund tracking table for patient and insurance refunds';
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `check_register` (
  `id` int NOT NULL AUTO_INCREMENT,
  `check_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `provider_check_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'External provider check ID (Checkeeper UUID)',
  `payee_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payee_address_line1` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payee_address_line2` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payee_city` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payee_state` varchar(2) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payee_zip` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payee_country` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'USA',
  `check_amount` decimal(10,2) NOT NULL,
  `check_memo` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `send_date` date NOT NULL,
  `express_delivery` tinyint(1) DEFAULT '0',
  `bank_account_id` int NOT NULL,
  `status` enum('created','ready','printed','mailed','failed','cancelled','voided') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'created',
  `tracking_number` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tracking_carrier` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estimated_delivery_date` date DEFAULT NULL,
  `actual_delivery_date` date DEFAULT NULL,
  `is_refund_check` tinyint(1) DEFAULT '0',
  `refund_request_id` int DEFAULT NULL,
  `provider_response` json DEFAULT NULL COMMENT 'Provider API response (Checkeeper or future providers)',
  `provider_pdf_base64` longtext COLLATE utf8mb4_unicode_ci COMMENT 'Base64 PDF payload returned by provider',
  `nonce` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Checkeeper idempotency key (unique per check creation)',
  `provider_letter_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'External provider letter/check ID (Checkeeper UUID for tracking)',
  `error_message` text COLLATE utf8mb4_unicode_ci COMMENT 'Error message when PostGrid API call fails or check delivery fails',
  `created_by_user_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `voided_at` timestamp NULL DEFAULT NULL,
  `voided_by_user_id` int DEFAULT NULL,
  `void_reason` enum('stale_check','wrong_address','wrong_patient','incorrect_amount','lost_in_mail','other') COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Standardized void reason for printed/mailed checks',
  `od_payment_reversed` tinyint(1) DEFAULT '0' COMMENT 'Whether Open Dental payment entry was reversed when check was voided',
  `void_notes` text COLLATE utf8mb4_unicode_ci COMMENT 'Additional context about why check was voided',
  PRIMARY KEY (`id`),
  UNIQUE KEY `check_number` (`check_number`),
  UNIQUE KEY `unique_refund_request` (`refund_request_id`),
  KEY `idx_check_number` (`check_number`),
  KEY `idx_postgrid_id` (`provider_check_id`),
  KEY `idx_status` (`status`),
  KEY `idx_refund_request` (`refund_request_id`),
  KEY `idx_send_date` (`send_date`),
  KEY `idx_is_refund` (`is_refund_check`),
  KEY `created_by_user_id` (`created_by_user_id`),
  KEY `voided_by_user_id` (`voided_by_user_id`),
  KEY `idx_status_failed` (`status`),
  KEY `idx_cancelled` (`status`,`check_number`),
  KEY `idx_void_tracking` (`status`,`void_reason`,`voided_at`),
  KEY `idx_provider_letter_id` (`provider_letter_id`),
  KEY `idx_check_register_nonce` (`nonce`),
  KEY `check_register_ibfk_1` (`bank_account_id`),
  CONSTRAINT `check_register_ibfk_1` FOREIGN KEY (`bank_account_id`) REFERENCES `bank_accounts` (`bank_account_id`),
  CONSTRAINT `check_register_ibfk_2` FOREIGN KEY (`refund_request_id`) REFERENCES `refund_requests` (`id`),
  CONSTRAINT `check_register_ibfk_3` FOREIGN KEY (`created_by_user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `check_register_ibfk_4` FOREIGN KEY (`voided_by_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Check register with PostGrid integration and tracking';
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `insurance_address_book` (
  `id` int NOT NULL AUTO_INCREMENT,
  `insurance_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address_line1` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address_line2` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `state` varchar(2) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'US state code',
  `zip` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Supports ZIP+4 format',
  `country` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'USA',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `is_active` tinyint(1) DEFAULT '1',
  `created_by_user_id` int NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_insurance_name` (`insurance_name`),
  KEY `idx_is_active` (`is_active`),
  KEY `created_by_user_id` (`created_by_user_id`),
  CONSTRAINT `insurance_address_book_ibfk_1` FOREIGN KEY (`created_by_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Reusable insurance company addresses for refund processing';
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `check_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `setting_value` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by_user_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`),
  KEY `idx_setting_key` (`setting_key`),
  KEY `updated_by_user_id` (`updated_by_user_id`),
  CONSTRAINT `check_settings_ibfk_1` FOREIGN KEY (`updated_by_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Check configuration key-value store';
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `n8n_workflow_executions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `n8n_execution_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `workflow_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `trigger_source` enum('webhook','manual','scheduled') COLLATE utf8mb4_unicode_ci NOT NULL,
  `trigger_data` json DEFAULT NULL,
  `status` enum('running','success','failed') COLLATE utf8mb4_unicode_ci NOT NULL,
  `error_message` text COLLATE utf8mb4_unicode_ci,
  `refund_request_id` int DEFAULT NULL,
  `check_register_id` int DEFAULT NULL,
  `started_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `completed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_n8n_execution_id` (`n8n_execution_id`),
  KEY `idx_workflow_name` (`workflow_name`),
  KEY `idx_status` (`status`),
  KEY `idx_refund_request` (`refund_request_id`),
  KEY `check_register_id` (`check_register_id`),
  CONSTRAINT `n8n_workflow_executions_ibfk_1` FOREIGN KEY (`refund_request_id`) REFERENCES `refund_requests` (`id`),
  CONSTRAINT `n8n_workflow_executions_ibfk_2` FOREIGN KEY (`check_register_id`) REFERENCES `check_register` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='n8n workflow automation tracking for webhooks and notifications';
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `refund_notification_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `notification_type` enum('new_request','failed_processing','check_delivered') COLLATE utf8mb4_unicode_ci NOT NULL,
  `recipient_emails` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Comma-separated staff email addresses (STAFF ONLY - no patient emails)',
  `is_enabled` tinyint(1) DEFAULT '1',
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `updated_by_user_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `notification_type` (`notification_type`),
  KEY `idx_notification_type` (`notification_type`),
  KEY `idx_is_enabled` (`is_enabled`),
  KEY `updated_by_user_id` (`updated_by_user_id`),
  CONSTRAINT `refund_notification_settings_ibfk_1` FOREIGN KEY (`updated_by_user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Email notification settings for staff notifications only (no patient emails)';
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `api_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `service` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'API service name (e.g., checkeeper, usps)',
  `endpoint` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'API endpoint called',
  `http_method` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'HTTP method (GET, POST, PUT, DELETE)',
  `request_payload` text COLLATE utf8mb4_unicode_ci COMMENT 'JSON request payload (sanitized - no sensitive data)',
  `request_headers` text COLLATE utf8mb4_unicode_ci COMMENT 'Request headers (sanitized)',
  `response_status` int DEFAULT NULL COMMENT 'HTTP response status code',
  `response_payload` text COLLATE utf8mb4_unicode_ci COMMENT 'JSON response payload',
  `response_headers` text COLLATE utf8mb4_unicode_ci COMMENT 'Response headers',
  `response_time_ms` int DEFAULT NULL COMMENT 'Response time in milliseconds',
  `is_error` tinyint(1) DEFAULT '0' COMMENT 'Whether the request resulted in an error',
  `error_message` text COLLATE utf8mb4_unicode_ci COMMENT 'Error message if request failed',
  `error_stack` text COLLATE utf8mb4_unicode_ci COMMENT 'Error stack trace for debugging',
  `check_register_id` int DEFAULT NULL COMMENT 'Related check_register ID if applicable',
  `refund_request_id` int DEFAULT NULL COMMENT 'Related refund_request ID if applicable',
  `user_id` int DEFAULT NULL COMMENT 'User who initiated the request',
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'IP address of the request origin',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_service` (`service`),
  KEY `idx_endpoint` (`endpoint`),
  KEY `idx_check_register` (`check_register_id`),
  KEY `idx_refund_request` (`refund_request_id`),
  KEY `idx_is_error` (`is_error`),
  KEY `idx_created_at` (`created_at`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `api_logs_ibfk_1` FOREIGN KEY (`check_register_id`) REFERENCES `check_register` (`id`) ON DELETE SET NULL,
  CONSTRAINT `api_logs_ibfk_2` FOREIGN KEY (`refund_request_id`) REFERENCES `refund_requests` (`id`) ON DELETE SET NULL,
  CONSTRAINT `api_logs_ibfk_3` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='API call logs for external service integrations (Checkeeper, USPS, etc.)';
/*!40101 SET character_set_client = @saved_cs_client */;

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE IF NOT EXISTS `remote_deposit_scanner` (
  `remote_deposit_scanner_id` bigint NOT NULL AUTO_INCREMENT,
  `date` date NOT NULL,
  `serial` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  PRIMARY KEY (`remote_deposit_scanner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;


-- =====================================================================
-- F5 fix (verification round 2): 12 more production-only tables that
-- F1 missed. Same out-of-band pattern. Currently 0 code references.
-- =====================================================================

SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS `zuub_audit_log` (
  `id` char(36) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `action_type` varchar(100) NOT NULL,
  `resource_type` varchar(100) NOT NULL,
  `resource_id` varchar(255) NOT NULL,
  `changes` json DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `status` varchar(50) NOT NULL,
  `error_message` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_zuub_audit_log_user` (`user_id`),
  KEY `idx_zuub_audit_log_action` (`action_type`),
  KEY `idx_zuub_audit_log_resource_type` (`resource_type`),
  KEY `idx_zuub_audit_log_resource_id` (`resource_id`),
  KEY `idx_zuub_audit_log_created` (`created_at`),
  KEY `idx_zuub_audit_log_user_action_created` (`user_id`,`action_type`,`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `zuub_clinic` (
  `id` char(36) NOT NULL,
  `org_id` char(36) NOT NULL,
  `zuub_clinic_id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `address_line1` varchar(255) NOT NULL,
  `address_line2` varchar(255) DEFAULT NULL,
  `city` varchar(100) NOT NULL,
  `state` varchar(2) NOT NULL,
  `zip` varchar(10) NOT NULL,
  `npi` varchar(20) NOT NULL,
  `tax_id` varchar(20) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` varchar(255) NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_zuub_clinic_zuub_clinic_id` (`zuub_clinic_id`),
  KEY `idx_zuub_clinic_org_id` (`org_id`),
  KEY `idx_zuub_clinic_state` (`state`),
  KEY `idx_zuub_clinic_npi` (`npi`),
  KEY `idx_zuub_clinic_tax_id` (`tax_id`),
  KEY `idx_zuub_clinic_created_at` (`created_at`),
  CONSTRAINT `fk_zuub_clinic_organization` FOREIGN KEY (`org_id`) REFERENCES `zuub_organization` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `zuub_organization` (
  `id` char(36) NOT NULL,
  `zuub_org_id` varchar(255) NOT NULL,
  `customer_id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` varchar(255) NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_zuub_organization_zuub_org_id` (`zuub_org_id`),
  UNIQUE KEY `uq_zuub_organization_customer_id` (`customer_id`),
  KEY `idx_zuub_organization_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `zuub_payer` (
  `id` char(36) NOT NULL,
  `zuub_payer_id` varchar(20) NOT NULL,
  `name` varchar(255) NOT NULL,
  `common_payer_id` varchar(50) DEFAULT NULL,
  `alternate_ids` json DEFAULT NULL,
  `features` json NOT NULL,
  `requirements` json NOT NULL,
  `address` json DEFAULT NULL,
  `contact` json DEFAULT NULL,
  `logo_url` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_zuub_payer_zuub_payer_id` (`zuub_payer_id`),
  KEY `idx_zuub_payer_name` (`name`),
  KEY `idx_zuub_payer_common_id` (`common_payer_id`),
  KEY `idx_zuub_payer_created_at` (`created_at`),
  KEY `idx_zuub_payer_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `zuub_payer_connection` (
  `id` char(36) NOT NULL,
  `clinic_id` char(36) NOT NULL,
  `payer_id` char(36) NOT NULL,
  `portal_id` char(36) NOT NULL,
  `variant_id` varchar(100) DEFAULT NULL,
  `status` varchar(50) NOT NULL,
  `interested_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `provisioned_at` timestamp NULL DEFAULT NULL,
  `registered_at` timestamp NULL DEFAULT NULL,
  `credentials_stored_at` timestamp NULL DEFAULT NULL,
  `last_validated_at` timestamp NULL DEFAULT NULL,
  `archived_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` varchar(255) NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_zuub_payer_connection_combo` (`clinic_id`,`payer_id`,`portal_id`,`variant_id`),
  KEY `idx_zuub_payer_connection_clinic` (`clinic_id`),
  KEY `idx_zuub_payer_connection_payer` (`payer_id`),
  KEY `idx_zuub_payer_connection_portal` (`portal_id`),
  KEY `idx_zuub_payer_connection_status` (`status`),
  KEY `idx_zuub_payer_connection_archived` (`archived_at`),
  KEY `idx_zuub_payer_connection_created` (`created_at`),
  CONSTRAINT `fk_zuub_payer_connection_clinic` FOREIGN KEY (`clinic_id`) REFERENCES `zuub_clinic` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_zuub_payer_connection_payer` FOREIGN KEY (`payer_id`) REFERENCES `zuub_payer` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_zuub_payer_connection_portal` FOREIGN KEY (`portal_id`) REFERENCES `zuub_portal` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `zuub_portal` (
  `id` char(36) NOT NULL,
  `payer_id` char(36) NOT NULL,
  `zuub_portal_id` varchar(100) NOT NULL,
  `name` varchar(255) NOT NULL,
  `variant_id` varchar(100) DEFAULT NULL,
  `variant_label` varchar(100) DEFAULT NULL,
  `auth_methods` json NOT NULL,
  `login_method` json NOT NULL,
  `usage_pattern` varchar(20) NOT NULL,
  `url` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_zuub_portal_portal_variant` (`zuub_portal_id`,`variant_id`),
  KEY `idx_zuub_portal_payer_id` (`payer_id`),
  KEY `idx_zuub_portal_variant` (`variant_id`),
  KEY `idx_zuub_portal_name` (`name`),
  KEY `idx_zuub_portal_created_at` (`created_at`),
  KEY `idx_zuub_portal_updated_at` (`updated_at`),
  CONSTRAINT `fk_zuub_portal_payer` FOREIGN KEY (`payer_id`) REFERENCES `zuub_payer` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `zuub_portal_credential` (
  `id` char(36) NOT NULL,
  `connection_id` char(36) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password_hash` varbinary(512) NOT NULL,
  `mfa_email` varbinary(512) DEFAULT NULL,
  `mfa_phone` varbinary(512) DEFAULT NULL,
  `mfa_totp_secret` varbinary(512) DEFAULT NULL,
  `login_method` varchar(50) NOT NULL,
  `validation_status` varchar(50) NOT NULL DEFAULT 'NotValidated',
  `validation_error` varchar(500) DEFAULT NULL,
  `validation_correlation_id` varchar(255) DEFAULT NULL,
  `validated_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` varchar(255) NOT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `updated_by` varchar(255) DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_zuub_portal_credential_connection` (`connection_id`),
  KEY `idx_zuub_portal_credential_status` (`validation_status`,`validated_at`),
  KEY `idx_zuub_portal_credential_validation_correlation_id` (`validation_correlation_id`),
  KEY `idx_zuub_portal_credential_created_at` (`created_at`),
  CONSTRAINT `fk_zuub_portal_credential_connection` FOREIGN KEY (`connection_id`) REFERENCES `zuub_payer_connection` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `zuub_portal_registration` (
  `id` char(36) NOT NULL,
  `clinic_id` char(36) NOT NULL,
  `portal_id` char(36) NOT NULL,
  `zuub_registration_id` varchar(255) DEFAULT NULL,
  `registered_email` varchar(255) NOT NULL,
  `registered_phone` varchar(20) DEFAULT NULL,
  `confirmation_status` varchar(50) NOT NULL DEFAULT 'Pending',
  `confirmed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_zuub_portal_registration_clinic_portal` (`clinic_id`,`portal_id`),
  UNIQUE KEY `uq_zuub_portal_registration_zuub_id` (`zuub_registration_id`),
  KEY `idx_zuub_portal_registration_status` (`confirmation_status`),
  KEY `idx_zuub_portal_registration_created` (`created_at`),
  KEY `fk_zuub_portal_registration_portal` (`portal_id`),
  CONSTRAINT `fk_zuub_portal_registration_clinic` FOREIGN KEY (`clinic_id`) REFERENCES `zuub_clinic` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_zuub_portal_registration_portal` FOREIGN KEY (`portal_id`) REFERENCES `zuub_portal` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `zuub_webhook_event` (
  `id` char(36) NOT NULL,
  `correlation_id` varchar(255) NOT NULL,
  `event_type` varchar(100) NOT NULL,
  `received_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `http_status` int DEFAULT NULL,
  `payload_size_bytes` int DEFAULT NULL,
  `payload_hash` varchar(64) NOT NULL,
  `signature_header` varchar(500) NOT NULL,
  `signature_valid` tinyint(1) NOT NULL,
  `processing_status` varchar(50) NOT NULL DEFAULT 'Received',
  `error_message` varchar(500) DEFAULT NULL,
  `retry_count` int NOT NULL DEFAULT '0',
  `last_retry_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_zuub_webhook_event_corr_received` (`correlation_id`,`received_at`),
  KEY `idx_zuub_webhook_event_corr` (`correlation_id`),
  KEY `idx_zuub_webhook_event_received_at` (`received_at`),
  KEY `idx_zuub_webhook_event_processing` (`processing_status`),
  KEY `idx_zuub_webhook_event_signature_valid` (`signature_valid`),
  KEY `idx_zuub_webhook_event_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `zuub_webhook_subscription` (
  `id` char(36) NOT NULL,
  `clinic_id` char(36) NOT NULL,
  `url` varchar(500) NOT NULL,
  `signature_secret` varbinary(512) NOT NULL,
  `event_types` json NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL,
  `last_tested_at` timestamp NULL DEFAULT NULL,
  `last_test_status` varchar(50) DEFAULT NULL,
  `last_test_error` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_zuub_webhook_subscription_clinic` (`clinic_id`),
  KEY `idx_zuub_webhook_subscription_active` (`is_active`),
  KEY `idx_zuub_webhook_subscription_created` (`created_at`),
  CONSTRAINT `fk_zuub_webhook_subscription_clinic` FOREIGN KEY (`clinic_id`) REFERENCES `zuub_clinic` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `request_audit_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `method` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'HTTP met-- Cleanup pass complete: 2 OpenDental-derived mirror tables excluded.
hod: GET, POST, PUT, DELETE, PATCH',
  `path` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'API endpoint path',
  `status_code` smallint NOT NULL COMMENT 'HTTP response status code',
  `duration_ms` int DEFAULT NULL COMMENT 'Request duration in milliseconds',
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Client IP (supports IPv6)',
  `user_agent` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_path_method` (`path`(100),`method`),
  KEY `idx_status_code` (`status_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='SOC 2 CC4 — API request audit trail';

CREATE TABLE IF NOT EXISTS `schema_migrations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `migration_file` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `executed_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `migration_file` (`migration_file`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
-- SEED DATA — Bootstrap roles, permissions, default admin, app settings
-- =====================================================================
-- All inserts are idempotent (INSERT IGNORE / ON DUPLICATE KEY UPDATE),
-- so this section is safe to re-run against an existing database.
--
-- Default admin credentials:
--   username:  admin
--   password:  ChangeMe123!
--   role:      super_admin
--   FLAG:      force_password_change = 1 (must be reset on first login)
--
-- bcrypt hash below is the real bcryptjs ($2b$12$…) digest of the
-- password "ChangeMe123!" and was verified before being embedded here.
-- Rotate this credential IMMEDIATELY in any production deployment.
-- =====================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- ---------------------------------------------------------------------
-- 1. Roles (system roles match what RBAC code expects)
--    Reference: nest-dental-app/src/shared/rbac/rbac.service.ts and the
--    role names used in migration 031_seed_recon_permissions.sql.
-- ---------------------------------------------------------------------
INSERT INTO `roles` (`role_name`, `display_name`, `description`, `is_system_role`, `created_at`, `updated_at`)
VALUES
  ('super_admin',          'Super Administrator',  'Full unrestricted access to every module and setting. Cannot be removed from any user automatically.', 1, NOW(), NOW()),
  ('admin_user',           'Administrator',        'Standard administrator: manage users, roles, providers, payroll, reconciliation, and audits.',         1, NOW(), NOW()),
  ('payroll_manager',      'Payroll Manager',      'Approve payroll runs, finalize quarterly audits, manage payroll settings and adjustments.',           1, NOW(), NOW()),
  ('payroll_user',         'Payroll User',         'Run payroll calculations, view and edit provider time entries, view reconciliation.',                 1, NOW(), NOW()),
  ('insurance_specialist', 'Insurance Specialist', 'Process ERAs, post claims to Open Dental, manage carrier rules and follow-up actions.',               1, NOW(), NOW()),
  ('viewer',               'Viewer',               'Read-only access to dashboards, reports, and payroll/reconciliation views.',                          1, NOW(), NOW())
ON DUPLICATE KEY UPDATE
  `display_name`   = VALUES(`display_name`),
  `description`    = VALUES(`description`),
  `is_system_role` = VALUES(`is_system_role`),
  `updated_at`     = NOW();

-- ---------------------------------------------------------------------
-- 2. Permission catalog — 54 permissions matching @Permissions(...) decorators
--    Generated by greping every @Permissions('...') usage across
--    nest-dental-app/src/. These EXACT strings are what the
--    permissions.guard.ts looks up at request time. Mismatched names
--    would cause 403 Forbidden on every non-super_admin call.
--    Source-of-truth: src/**/*.controller.ts @Permissions decorators.
-- ---------------------------------------------------------------------
INSERT INTO `permissions` (`permission_name`, `display_name`, `description`, `category`, `resource_type`, `created_at`, `is_active`) VALUES
  -- audit (4)
  ('audit.read',                  'Read Audit Log',             'View audit log entries and PHI access log',                              'audit',         'audit_log',   NOW(), 1),
  ('audit.export',                'Export Audit Log',           'Export audit log to CSV/PDF for compliance reporting',                   'audit',         'audit_log',   NOW(), 1),
  ('audit.manage',                'Manage Audit Configuration', 'Configure audit retention policies and alert rules',                     'audit',         'audit_log',   NOW(), 1),
  ('audit.delete',                'Delete Audit Entries',       'Purge audit entries (typically only after retention period)',            'audit',         'audit_log',   NOW(), 1),

  -- check printing (3)
  ('check.view',                  'View Check Register',        'View issued checks, status, and tracking',                               'checks',        'check',       NOW(), 1),
  ('check.create',                'Create Checks',              'Create check entries via Checkeeper integration',                        'checks',        'check',       NOW(), 1),
  ('check.export',                'Export Check Register',      'Export the check register to CSV/PDF',                                   'checks',        'check',       NOW(), 1),

  -- era / claims posting (3)
  ('era.review',                  'Review ERAs',                'Review ERA payments, claim matches, and service-line decisions',         'era',           NULL,          NOW(), 1),
  ('era.edit',                    'Edit ERAs',                  'Modify ERA postings, exclusions, write-off decisions',                   'era',           NULL,          NOW(), 1),
  ('era.post',                    'Post ERAs to OpenDental',    'Push reconciled ERAs to OpenDental (frontend gate; backend uses era.edit)','era',          NULL,          NOW(), 1),

  -- grooming (4)
  ('grooming.view',               'View Grooming Items',        'View daily grooming flags and recommendations',                          'grooming',      NULL,          NOW(), 1),
  ('grooming.run',                'Run Grooming Sweep',         'Trigger a fresh grooming sweep over the target date',                    'grooming',      NULL,          NOW(), 1),
  ('grooming.execute',            'Execute Grooming Actions',   'Push approved grooming recommendations into OpenDental',                 'grooming',      NULL,          NOW(), 1),
  ('grooming.edit',               'Edit Grooming Recommendations','Edit notes, override flags, mark items resolved',                      'grooming',      NULL,          NOW(), 1),
  ('grooming.admin',              'Administer Grooming Module', 'Configure grooming settings and thresholds',                             'grooming',      NULL,          NOW(), 1),

  -- payroll (9)
  ('payroll.view',                'View Payroll (all providers)','View payroll calculations, batches, and reports for ALL providers',    'payroll',       NULL,          NOW(), 1),
  ('payroll.view_own',            'View Own Payroll',           'Provider-scoped: view ONLY the logged-in user''s own payroll history',   'payroll',       NULL,          NOW(), 1),
  ('payroll.edit',                'Edit Payroll',               'Edit time entries, additions, manual adjustments',                       'payroll',       NULL,          NOW(), 1),
  ('payroll.calculate',           'Calculate Payroll',          'Trigger payroll calculations for one or more providers',                 'payroll',       NULL,          NOW(), 1),
  ('payroll.batch_processing',    'Run Batch Payroll',          'Run batch payroll generation and PDF assembly',                          'payroll',       NULL,          NOW(), 1),
  ('payroll.audit',               'Run Payroll Audit',          'Run and finalize quarterly payroll audits',                              'payroll',       NULL,          NOW(), 1),
  ('payroll.settings',            'Manage Payroll Settings',    'Edit compensation rates, bonus rates, and payroll configuration',        'payroll',       NULL,          NOW(), 1),
  ('payroll.audit_periods.view',  'View Audit Period Data',     'View pay period category breakdowns before quarterly audit',             'payroll',       NULL,          NOW(), 1),
  ('payroll.audit_periods.edit',  'Edit Audit Period Data',     'Modify pay period category values for audit corrections',                'payroll',       NULL,          NOW(), 1),

  -- permissions catalog (3)
  ('permissions.create',          'Create Permissions',         'Add new permission rows to the catalog',                                 'permissions',   'permission',  NOW(), 1),
  ('permissions.update',          'Update Permissions',         'Edit permission display names, descriptions, categories',                'permissions',   'permission',  NOW(), 1),
  ('permissions.delete',          'Delete Permissions',         'Remove permissions from the catalog',                                    'permissions',   'permission',  NOW(), 1),

  -- providers (5)
  ('providers.view',              'View Providers',             'View provider list and details',                                         'providers',     'provider',    NOW(), 1),
  ('providers.create',            'Create Providers',           'Add new provider records and link to OpenDental',                        'providers',     'provider',    NOW(), 1),
  ('providers.edit',              'Edit Providers',             'Edit provider metadata and OD linkage',                                  'providers',     'provider',    NOW(), 1),
  ('providers.delete',            'Delete Providers',           'Deactivate provider records',                                            'providers',     'provider',    NOW(), 1),
  ('providers.manage_rates',      'Manage Compensation Rates',  'Edit compensation rates, daily guarantees, and bonus structures',        'providers',     'provider',    NOW(), 1),

  -- reconciliation (3)
  ('recon.view',                  'View Reconciliation',        'View bank reconciliation dashboards (weekly/daily/monthly)',             'reconciliation', NULL,         NOW(), 1),
  ('recon.edit',                  'Edit Reconciliation',        'Create/delete manual links, refresh OD data, upload CSV, re-run',        'reconciliation', NULL,         NOW(), 1),
  ('recon.close',                 'Close/Reopen Month',         'Close or reopen monthly reconciliation periods',                         'reconciliation', NULL,         NOW(), 1),

  -- refunds (7)
  ('refund.view',                 'View Refund Requests',       'View refund requests and their status',                                  'refunds',       'refund',      NOW(), 1),
  ('refund.create',               'Create Refund Requests',     'Submit new refund requests (patient or insurance)',                      'refunds',       'refund',      NOW(), 1),
  ('refund.edit',                 'Edit Refund Requests',       'Modify refund requests before approval',                                 'refunds',       'refund',      NOW(), 1),
  ('refund.approve',              'Approve Refund Requests',    'Approve or reject refund requests; trigger check issuance',              'refunds',       'refund',      NOW(), 1),
  ('refund.process',              'Process Refund Requests',    'Drive refund requests through the processing pipeline',                  'refunds',       'refund',      NOW(), 1),
  ('refund.delete',               'Delete Refund Requests',     'Remove refund requests (typically only in draft/pending states)',        'refunds',       'refund',      NOW(), 1),
  ('refund.manage_addresses',     'Manage Refund Addresses',    'Maintain the insurance address book used for refund mailings',           'refunds',       'refund',      NOW(), 1),

  -- roles (4)
  ('roles.read',                  'Read Roles',                 'List roles and view their permissions',                                  'roles',         'role',        NOW(), 1),
  ('roles.create',                'Create Roles',               'Create new roles',                                                       'roles',         'role',        NOW(), 1),
  ('roles.update',                'Update Roles',               'Edit role metadata and assigned permissions',                            'roles',         'role',        NOW(), 1),
  ('roles.delete',                'Delete Roles',               'Delete roles (cascades to user_roles and role_permissions)',             'roles',         'role',        NOW(), 1),

  -- system (1)
  ('system.settings',             'Manage System Settings',     'Edit system_settings, practice_rule_settings, database_connections',     'system',        NULL,          NOW(), 1),

  -- users (10)
  ('users.view',                  'View Users (list)',          'View summary list of user accounts',                                     'users',         'user',        NOW(), 1),
  ('users.read',                  'Read User Detail',           'View full user account details',                                         'users',         'user',        NOW(), 1),
  ('users.create',                'Create Users',               'Create new user accounts',                                               'users',         'user',        NOW(), 1),
  ('users.update',                'Update Users',               'Edit user account details (excluding password)',                         'users',         'user',        NOW(), 1),
  ('users.edit',                  'Edit Users',                 'Alternate edit permission used by some endpoints',                       'users',         'user',        NOW(), 1),
  ('users.delete',                'Delete Users',               'Deactivate or remove user accounts',                                     'users',         'user',        NOW(), 1),
  ('users.lock',                  'Lock Users',                 'Lock a user account (sets locked_until)',                                'users',         'user',        NOW(), 1),
  ('users.unlock',                'Unlock Users',               'Unlock a previously locked user account',                                'users',         'user',        NOW(), 1),
  ('users.password_reset',        'Reset User Passwords',       'Trigger administrative password resets for any user',                    'users',         'user',        NOW(), 1)
ON DUPLICATE KEY UPDATE
  `display_name` = VALUES(`display_name`),
  `description`  = VALUES(`description`),
  `category`     = VALUES(`category`),
  `resource_type`= VALUES(`resource_type`),
  `is_active`    = VALUES(`is_active`);

-- ---------------------------------------------------------------------
-- 3. Role → Permission grants (matrix)
--    NOTE: super_admin bypasses the permissions check entirely
--    (permissions.guard.ts:48, rbac.service.ts:79,99). The grants below
--    still get inserted for super_admin so the catalog view in the UI
--    shows it owning every permission — but those rows are unreachable
--    code paths in practice.
-- ---------------------------------------------------------------------

-- super_admin → every permission
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`, `granted_at`)
SELECT r.id, p.id, NOW()
FROM `roles` r CROSS JOIN `permissions` p
WHERE r.role_name = 'super_admin';

-- admin_user → everything except destructive cascade-delete actions
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`, `granted_at`)
SELECT r.id, p.id, NOW()
FROM `roles` r CROSS JOIN `permissions` p
WHERE r.role_name = 'admin_user'
  AND p.permission_name NOT IN (
    'roles.delete','permissions.delete','audit.delete','users.delete','providers.delete'
  );

-- payroll_manager
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`, `granted_at`)
SELECT r.id, p.id, NOW()
FROM `roles` r CROSS JOIN `permissions` p
WHERE r.role_name = 'payroll_manager'
  AND p.permission_name IN (
    'audit.read','audit.export',
    'providers.view','providers.edit','providers.manage_rates',
    'payroll.view','payroll.view_own','payroll.edit','payroll.calculate','payroll.batch_processing',
    'payroll.audit','payroll.settings',
    'payroll.audit_periods.view','payroll.audit_periods.edit',
    'recon.view','recon.edit',
    'users.view','users.read'
  );

-- payroll_user
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`, `granted_at`)
SELECT r.id, p.id, NOW()
FROM `roles` r CROSS JOIN `permissions` p
WHERE r.role_name = 'payroll_user'
  AND p.permission_name IN (
    'providers.view',
    'payroll.view','payroll.view_own','payroll.edit','payroll.calculate',
    'payroll.audit_periods.view',
    'recon.view','recon.edit'
  );

-- insurance_specialist
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`, `granted_at`)
SELECT r.id, p.id, NOW()
FROM `roles` r CROSS JOIN `permissions` p
WHERE r.role_name = 'insurance_specialist'
  AND p.permission_name IN (
    'era.review','era.edit','era.post',
    'recon.view','recon.edit',
    'refund.view','refund.create','refund.edit','refund.process','refund.manage_addresses',
    'check.view','check.create',
    'grooming.view','grooming.edit','grooming.run','grooming.execute',
    'audit.read'
  );

-- viewer (read-only — every *.view, *.read, *.review)
INSERT IGNORE INTO `role_permissions` (`role_id`, `permission_id`, `granted_at`)
SELECT r.id, p.id, NOW()
FROM `roles` r CROSS JOIN `permissions` p
WHERE r.role_name = 'viewer'
  AND p.permission_name IN (
    'audit.read',
    'check.view',
    'era.review',
    'grooming.view',
    'payroll.view','payroll.view_own','payroll.audit_periods.view',
    'providers.view',
    'recon.view',
    'refund.view',
    'roles.read',
    'users.view','users.read'
  );

-- ---------------------------------------------------------------------
-- 4. Sample provider (allows the admin to be linked to a provider record)
--    `providers` has no UNIQUE constraint on `name` and `open_dental_provnum`
--    is nullable (NULL ≠ NULL under UNIQUE), so `INSERT IGNORE` alone is
--    NOT idempotent — a `WHERE NOT EXISTS` guard is required.
-- ---------------------------------------------------------------------
INSERT INTO `providers`
  (`name`, `open_dental_provnum`, `provider_type`, `is_active`, `created_at`, `updated_at`)
SELECT 'System Administrator', NULL, 'general_dentist', 1, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM `providers` WHERE `name` = 'System Administrator'
);

-- ---------------------------------------------------------------------
-- 5. Default super_admin users
--    All three rows below carry a real bcryptjs $2b$12$… hash of the
--    placeholder password "ChangeMe123!" (verified valid before embed)
--    AND force_password_change = 1, so every account is forced to set
--    its own password on first login. Each user has an independent
--    salt — no two share the same hash, even though the underlying
--    password string is identical at seed time.
-- ---------------------------------------------------------------------
INSERT INTO `users`
  (`username`, `email`, `password_hash`, `salt`, `first_name`, `last_name`,
   `is_active`, `failed_login_attempts`, `password_changed_at`,
   `force_password_change`, `password_history`, `created_at`, `updated_at`)
VALUES
  ('admin',
   'admin@example.local',
   '$2b$12$NcYAGFt.pZUYd64trVxSQOHm5Irv6L9aKHTRF.8rnsoDH4Eq6yNV2',
   '$2b$12$NcYAGFt.pZUYd64trVxSQO',
   'System', 'Administrator',
   1, 0, NOW(),
   1,
   JSON_ARRAY(),
   NOW(), NOW()),
  ('gary',
   'gary@svdc.dental',
   '$2b$12$QTsgusWTu5IX37pgmrPzYOmyxoFetQNdu9y91kN.wI89mA/YhEpFu',
   '$2b$12$QTsgusWTu5IX37pgmrPzYO',
   'Gary', 'Lloyd',
   1, 0, NOW(),
   1,
   JSON_ARRAY(),
   NOW(), NOW()),
  ('matthew',
   'matthew@salinasvalleydentalcare.com',
   '$2b$12$gjtEfHQrnjBuGaZ.j7r32ukNXrnb/RIjbi4udpCSRTaKvCmbazNjq',
   '$2b$12$gjtEfHQrnjBuGaZ.j7r32u',
   'Matthew', 'Admin',
   1, 0, NOW(),
   1,
   JSON_ARRAY(),
   NOW(), NOW())
ON DUPLICATE KEY UPDATE
  `email`                = VALUES(`email`),
  `password_hash`        = VALUES(`password_hash`),
  `salt`                 = VALUES(`salt`),
  `is_active`            = VALUES(`is_active`),
  `force_password_change`= VALUES(`force_password_change`),
  `updated_at`           = NOW();

-- Map admin / gary / matthew → super_admin role
INSERT IGNORE INTO `user_roles` (`user_id`, `role_id`, `assigned_at`)
SELECT u.id, r.id, NOW()
FROM `users` u
CROSS JOIN `roles` r
WHERE u.username IN ('admin', 'gary', 'matthew')
  AND r.role_name = 'super_admin';

-- ---------------------------------------------------------------------
-- 6. practice_rule_settings defaults (from migrations 008 and 011)
-- ---------------------------------------------------------------------
INSERT INTO `practice_rule_settings` (`setting_key`, `setting_value`, `setting_type`, `category`, `description`) VALUES
  ('NEW_PATIENT_XRAY_WRITEOFF',      'true',  'boolean', 'rules',      'Auto-write-off new patient x-ray frequency denial as professional courtesy'),
  ('FMX_COMBINATION_WRITEOFF',       'true',  'boolean', 'rules',      'Auto-write-off cross-coded component x-rays (D0272, D0274) to FMX (D0210)'),
  ('OVERPAYMENT_FLAG',               'true',  'boolean', 'rules',      'Flag when insurance paid more than posted fee'),
  ('DUPLICATE_PAYMENT_CHECK',        'true',  'boolean', 'rules',      'Flag possible duplicate payments (always blocking)'),
  ('CARRIER_UNDERPAYMENT_FLAG',      'true',  'boolean', 'rules',      'Flag when carrier paid less than their own allowed amount'),
  ('DENIED_CLAIM_FLAG',              'true',  'boolean', 'rules',      'Flag $0 payment claims for review (appeal decision)'),
  ('PI_ADJUSTMENT_FLAG',             'true',  'boolean', 'rules',      'Flag PI adjustments for review unless carrier rule overrides'),
  ('CR_ADJUSTMENT_FLAG',             'true',  'boolean', 'rules',      'Flag CR (correction) adjustments — always blocking'),
  ('overpayment_blocking_threshold', '50',    'number',  'thresholds', 'Overpayment amount ($) above which flag is blocking (below is warning)'),
  ('underpayment_tolerance',         '0.50',  'number',  'thresholds', 'Allowed rounding tolerance ($) before underpayment flag triggers'),
  ('auto_post_enabled',              'true',  'boolean', 'posting',    'Allow auto-posting of claims when no flags are present'),
  ('writeoff_negative_zero_out',     'true',  'boolean', 'posting',    'Zero out negative writeoffs on non-reversal claims'),
  ('balance_amount_threshold',       '0.02',  'number',  'thresholds', 'ERA balance check: auto-accept rounding differences up to this amount ($)'),
  ('balance_percentage_threshold',   '0.01',  'number',  'thresholds', 'ERA balance check: auto-accept differences up to this percentage (0.01 = 1%)'),
  ('overpayment_adj_type',           '',      'string',  'posting',    'OD DefNum for adjustment type used when insurance allows more than ProcFee')
ON DUPLICATE KEY UPDATE
  `setting_value` = VALUES(`setting_value`),
  `setting_type`  = VALUES(`setting_type`),
  `category`      = VALUES(`category`),
  `description`   = VALUES(`description`);

-- ---------------------------------------------------------------------
-- 7. system_settings — minimal app metadata
-- ---------------------------------------------------------------------
INSERT INTO `system_settings`
  (`setting_key`, `setting_value`, `setting_type`, `description`, `is_encrypted`, `created_at`, `updated_at`)
VALUES
  ('app_name',              'OpenDental Companion',         'string',  'Application display name shown in headers',                                          0, NOW(), NOW()),
  ('app_version',           '1.0.0',                        'string',  'Current application version',                                                        0, NOW(), NOW()),
  ('timezone',              'America/Los_Angeles',          'string',  'Default IANA timezone for date display and pay-period boundaries',                   0, NOW(), NOW()),
  ('password_min_length',   '12',                           'number',  'Minimum allowed password length',                                                    0, NOW(), NOW()),
  ('session_idle_minutes',  '30',                           'number',  'Idle minutes before automatic session expiry',                                       0, NOW(), NOW()),
  ('phi_audit_retention_years', '6',                        'number',  'Retention period for phi_access_log rows (HIPAA requires ≥6 years)',                0, NOW(), NOW())
ON DUPLICATE KEY UPDATE
  `setting_value` = VALUES(`setting_value`),
  `setting_type`  = VALUES(`setting_type`),
  `description`   = VALUES(`description`),
  `updated_at`    = NOW();

-- ---------------------------------------------------------------------
-- 8. stedi_poll_state — singleton row required by the Stedi 835 poller
--    (mirrors migration 022_stedi_poll_state.sql seed)
-- ---------------------------------------------------------------------
INSERT INTO `stedi_poll_state` (`id`, `last_poll_processed_at`)
VALUES (1, NULL)
ON DUPLICATE KEY UPDATE `id` = `id`;

-- ---------------------------------------------------------------------
-- 9. grooming_settings — thresholds and feature flags read at module
--    bootstrap by grooming-settings.service.ts. Empty table means the
--    grooming module falls back to in-code defaults; seeding makes the
--    config visible/editable in the admin UI.
-- ---------------------------------------------------------------------
INSERT INTO `grooming_settings` (`setting_key`, `setting_value`, `setting_type`, `category`, `description`) VALUES
  ('lapsed_patient_months',   '18',     'number',  'thresholds', 'Months since last visit before a patient is flagged as lapsed'),
  ('balance_warning_amount',  '100',    'number',  'thresholds', 'Patient outstanding balance ($) at or above which a flag is raised'),
  ('annual_max_warning',      '200',    'number',  'thresholds', 'Annual maximum remaining ($) below which a flag is raised'),
  ('fluoride_age_cutoff',     '14',     'number',  'thresholds', 'Maximum patient age (years) for fluoride coverage flag'),
  ('fluoride_cash_fee',       '38.00',  'number',  'fees',       'Cash fee ($) presented for fluoride when not covered'),
  ('xray_recheck_months',     '12',     'number',  'thresholds', 'Months between recommended BWX x-ray sets'),
  ('pano_recheck_months',     '60',     'number',  'thresholds', 'Months between recommended panoramic x-rays'),
  ('probing_recheck_months',  '12',     'number',  'thresholds', 'Months between recommended periodontal probings'),
  ('exam_recheck_months',     '6',      'number',  'thresholds', 'Months between recommended routine exams'),
  ('auto_write_note',         'false',  'boolean', 'features',   'Automatically write the generated note into the OD appointment record'),
  ('require_approval',        'true',   'boolean', 'features',   'Require a user to approve each grooming recommendation before execution'),
  ('membership_check_enabled','true',   'boolean', 'features',   'Verify discount-plan membership status during grooming runs')
ON DUPLICATE KEY UPDATE
  `setting_value` = VALUES(`setting_value`),
  `setting_type`  = VALUES(`setting_type`),
  `category`      = VALUES(`category`),
  `description`   = VALUES(`description`);

-- ---------------------------------------------------------------------
-- 10. migration_history — CRITICAL: mark all 74 migration files as
--     already executed so the runtime migration runner
--     (database-init.service.ts:185) skips them. Without this, the
--     migrator would attempt to re-apply non-idempotent ALTER TABLE
--     statements on first boot and crash the app.
--     Matches the runner's own INSERT shape:
--       INSERT IGNORE INTO migration_history (migration_name, execution_time_ms, success) VALUES (?, 0, 1)
-- ---------------------------------------------------------------------
INSERT IGNORE INTO `migration_history` (`migration_name`, `execution_time_ms`, `success`, `executed_at`) VALUES
  ('000_base_schema.sql',                          0, 1, NOW()),
  ('001_create_provider_time_entries.sql',         0, 1, NOW()),
  ('002_add_quarterly_audit_tables.sql',           0, 1, NOW()),
  ('003_add_category_audit_columns.sql',           0, 1, NOW()),
  ('004_add_audit_period_permissions.sql',         0, 1, NOW()),
  ('005_add_adjustment_amount_columns.sql',        0, 1, NOW()),
  ('006_add_audit_applied_tracking.sql',           0, 1, NOW()),
  ('007_add_open_dental_user_linking.sql',         0, 1, NOW()),
  ('008_create_practice_rule_settings.sql',        0, 1, NOW()),
  ('009_create_era_tables.sql',                    0, 1, NOW()),
  ('010_create_posting_results.sql',               0, 1, NOW()),
  ('011_era_audit_fixes.sql',                      0, 1, NOW()),
  ('012_add_proc_fee_column.sql',                  0, 1, NOW()),
  ('013_era_phase2_schema.sql',                    0, 1, NOW()),
  ('014_add_reason_under_paid.sql',                0, 1, NOW()),
  ('015_add_manually_posted_status.sql',           0, 1, NOW()),
  ('016_add_od_claim_type_status.sql',             0, 1, NOW()),
  ('017_add_contracted_fee_column.sql',            0, 1, NOW()),
  ('018_add_denial_closed_action_type.sql',        0, 1, NOW()),
  ('019_clp02_statuses.sql',                       0, 1, NOW()),
  ('020_phase3a_stedi_integration.sql',            0, 1, NOW()),
  ('021_stedi_transactions.sql',                   0, 1, NOW()),
  ('022_stedi_poll_state.sql',                     0, 1, NOW()),
  ('023_dashboard_indexes.sql',                    0, 1, NOW()),
  ('024_rename_type_mismatch.sql',                 0, 1, NOW()),
  ('025_mismatch_auto_resolve.sql',                0, 1, NOW()),
  ('026_add_od_pat_num.sql',                       0, 1, NOW()),
  ('027_create_bank_tables.sql',                   0, 1, NOW()),
  ('028_create_teller_bank_accounts.sql',          0, 1, NOW()),
  ('029_add_entra_object_id.sql',                  0, 1, NOW()),
  ('030_create_deposit_recon_tables.sql',          0, 1, NOW()),
  ('031_seed_recon_permissions.sql',               0, 1, NOW()),
  ('032_create_remote_deposits.sql',               0, 1, NOW()),
  ('033_create_checkeeper_bank_accounts.sql',      0, 1, NOW()),
  ('034_create_archive_tables.sql',                0, 1, NOW()),
  ('035_add_recon_performance_indexes.sql',        0, 1, NOW()),
  ('036_add_missing_recon_indexes.sql',            0, 1, NOW()),
  ('037_recon_audit_and_snapshots.sql',            0, 1, NOW()),
  ('038_backfill_data_quality.sql',                0, 1, NOW()),
  ('039_fix_recon_links_constraint_and_enum.sql',  0, 1, NOW()),
  ('040_recon_links_patient_support.sql',          0, 1, NOW()),
  ('041_create_od_patient_payments.sql',           0, 1, NOW()),
  ('042_era_consolidation.sql',                    0, 1, NOW()),
  ('043_add_contracted_fee_column.sql',            0, 1, NOW()),
  ('044_create_era_audit_events.sql',              0, 1, NOW()),
  ('045_create_cc_funding_tables.sql',             0, 1, NOW()),
  ('046_create_carecredit_tables.sql',             0, 1, NOW()),
  ('046_fix_cc_funding_txn_parent_ref.sql',        0, 1, NOW()),
  ('047_cc_chargebacks_adjustments.sql',           0, 1, NOW()),
  ('047_od_patient_payments_retref.sql',           0, 1, NOW()),
  ('048_cc_funding_txns_parent_retref.sql',        0, 1, NOW()),
  ('049_od_patient_payments_auth_code.sql',        0, 1, NOW()),
  ('050_recon_links_cc_carecredit.sql',            0, 1, NOW()),
  ('051_create_sunbit_tables.sql',                 0, 1, NOW()),
  ('052_recon_links_auto_amount_date_mismatch.sql',0, 1, NOW()),
  ('053_recon_links_cc_funding_batch.sql',         0, 1, NOW()),
  ('054_cc_funding_txns_denorm_funding_date.sql',  0, 1, NOW()),
  ('055_recon_links_auto_cc_batch_match_type.sql', 0, 1, NOW()),
  ('056_recon_links_auto_cc_monthly_fee_match_type.sql',0,1,NOW()),
  ('057_era_payments_no_deposit_expected.sql',     0, 1, NOW()),
  ('058_era_claims_secondary_awaiting_primary.sql',0, 1, NOW()),
  ('059_era_claims_cross_code_case.sql',           0, 1, NOW()),
  ('060_era_service_lines_excluded.sql',           0, 1, NOW()),
  ('061_era_claims_case_b_allocation.sql',         0, 1, NOW()),
  ('062_zuub_module_1_platform_setup.sql',         0, 1, NOW()),
  ('063_zuub_carry_forward_062_addenda.sql',       0, 1, NOW()),
  ('064_zuub_idempotency_keys.sql',                0, 1, NOW()),
  ('065_zuub_webhook_event_clinic_id.sql',         0, 1, NOW()),
  ('066_zuub_credential_vault_sync.sql',           0, 1, NOW()),
  ('067_zuub_iv_claims_webhook_config.sql',        0, 1, NOW()),
  ('068_zuub_audit_cleanup.sql',                   0, 1, NOW()),
  ('069_zuub_perf_indexes.sql',                    0, 1, NOW()),
  ('combined_002_006_quarterly_audit.sql',         0, 1, NOW()),
  ('remote_deposit.sql',                           0, 1, NOW());

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
-- END SEED DATA
-- =====================================================================
