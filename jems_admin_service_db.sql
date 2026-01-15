-- ============================================
-- JEMS Admin Service Database Setup
-- ============================================
-- This file contains PostgreSQL queries for:
-- 1. Database creation
-- 2. Table creation with constraints
-- 3. Sample data insertion
-- ============================================

-- Drop database if exists (use with caution in production)
-- DROP DATABASE IF EXISTS jems_admin;

-- Create database
CREATE DATABASE jems_admin;

-- Connect to the database
\c jems_admin;

-- ============================================
-- ENUM Types
-- ============================================

CREATE TYPE "VendorType" AS ENUM ('METAL', 'ALLOY', 'DIAMOND', 'STONE', 'COMPONENT', 'MIXED');
CREATE TYPE "VendorStatus" AS ENUM ('ACTIVE', 'INACTIVE');

-- ============================================
-- TABLES CREATION
-- ============================================

-- Tenant Table
CREATE TABLE "Tenant" (
    "tenant_id" SERIAL PRIMARY KEY,
    "name" TEXT NOT NULL,
    "domain" TEXT NOT NULL UNIQUE,
    "plan" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Department Table
CREATE TABLE "Department" (
    "department_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "department_code" TEXT NOT NULL UNIQUE,
    "department_name" TEXT NOT NULL,
    "description" TEXT,
    "department_type" TEXT,
    "location_id" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "Department_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "Tenant"("tenant_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Role Table
CREATE TABLE "Role" (
    "id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "role_code" TEXT NOT NULL UNIQUE,
    "role_name" TEXT NOT NULL,
    "role_description" TEXT,
    "is_active" BOOLEAN NOT NULL,
    "created_by" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_by" TEXT,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "Role_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "Tenant"("tenant_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Employee Table
CREATE TABLE "Employee" (
    "employee_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "employee_name" TEXT NOT NULL,
    "employee_code" TEXT,
    "department_id" INTEGER NOT NULL,
    "role_id" TEXT NOT NULL,
    "email" TEXT,
    "mobile_number" TEXT NOT NULL,
    "date_of_joining" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "location_id" TEXT,
    "subsidiary_id" TEXT,
    "supervisor_id" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_by" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_by" TEXT,
    "updated_at" TIMESTAMP(3),
    CONSTRAINT "Employee_tenant_id_fkey" FOREIGN KEY ("tenant_id") REFERENCES "Tenant"("tenant_id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "Employee_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "Department"("department_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Customer Table
CREATE TABLE "Customer" (
    "customer_id" SERIAL PRIMARY KEY,
    "customer_code" TEXT NOT NULL UNIQUE,
    "customer_name" TEXT NOT NULL,
    "mobilenumber" TEXT NOT NULL,
    "email_id" TEXT,
    "address" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'inactive',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL
);

-- Vendor Table
CREATE TABLE "Vendor" (
    "id" SERIAL PRIMARY KEY,
    "tenantId" INTEGER NOT NULL,
    "vendorCode" TEXT,
    "vendorName" TEXT NOT NULL,
    "vendorType" "VendorType" NOT NULL,
    "contactPerson" TEXT,
    "phone" TEXT,
    "email" TEXT,
    "gstin" TEXT,
    "addressLine1" TEXT,
    "addressLine2" TEXT,
    "city" TEXT,
    "state" TEXT,
    "country" TEXT,
    "pincode" TEXT,
    "status" "VendorStatus" NOT NULL DEFAULT 'ACTIVE',
    "remarks" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),
    CONSTRAINT "Vendor_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant"("tenant_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX "Department_tenant_id_idx" ON "Department"("tenant_id");
CREATE INDEX "Role_tenant_id_idx" ON "Role"("tenant_id");
CREATE INDEX "Employee_tenant_id_idx" ON "Employee"("tenant_id");
CREATE INDEX "Employee_department_id_idx" ON "Employee"("department_id");
CREATE INDEX "Vendor_tenantId_idx" ON "Vendor"("tenantId");

-- ============================================
-- SAMPLE DATA INSERTION
-- ============================================

-- Insert Tenant data
INSERT INTO "Tenant" ("name", "domain", "plan", "is_active", "created_at") VALUES
('JEM Manufacturing', 'jems.local', 'premium', true, CURRENT_TIMESTAMP),
('JEM Retail', 'jems-retail.local', 'standard', true, CURRENT_TIMESTAMP),
('JEM Wholesale', 'jems-wholesale.local', 'premium', true, CURRENT_TIMESTAMP),
('JEM Export', 'jems-export.local', 'enterprise', true, CURRENT_TIMESTAMP),
('JEM Custom', 'jems-custom.local', 'standard', true, CURRENT_TIMESTAMP),
('JEM Boutique', 'jems-boutique.local', 'premium', false, CURRENT_TIMESTAMP);

-- Insert Department data
INSERT INTO "Department" ("tenant_id", "department_code", "department_name", "description", "department_type", "is_active", "created_at", "updated_at") VALUES
(1, 'DEPT001', 'Manufacturing', 'Main manufacturing department', 'PRODUCTION', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'DEPT002', 'Quality Control', 'Quality assurance department', 'QA', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'DEPT003', 'Design', 'Design and development department', 'DESIGN', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'DEPT004', 'Packaging', 'Packaging and shipping department', 'LOGISTICS', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'DEPT005', 'Inventory', 'Inventory management department', 'WAREHOUSE', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 'DEPT001', 'Sales', 'Sales department', 'SALES', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 'DEPT002', 'Customer Service', 'Customer service department', 'SUPPORT', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(3, 'DEPT001', 'Wholesale Operations', 'Wholesale operations department', 'SALES', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert Role data
INSERT INTO "Role" ("tenant_id", "role_code", "role_name", "role_description", "is_active", "created_at", "updated_at") VALUES
(1, 'ROLE001', 'Admin', 'System administrator role', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'ROLE002', 'Manager', 'Department manager role', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'ROLE003', 'Supervisor', 'Supervisor role', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'ROLE004', 'Employee', 'Regular employee role', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'ROLE005', 'Quality Inspector', 'Quality inspection role', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'ROLE006', 'Designer', 'Jewelry designer role', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 'ROLE001', 'Sales Manager', 'Sales manager role', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 'ROLE002', 'Sales Executive', 'Sales executive role', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert Employee data
INSERT INTO "Employee" ("tenant_id", "employee_name", "employee_code", "department_id", "role_id", "email", "mobile_number", "date_of_joining", "address", "is_active", "created_at") VALUES
(1, 'John Doe', 'EMP001', 1, 'ROLE001', 'john.doe@jems.com', '9876543210', '2024-01-15', '123 Main Street, City', true, CURRENT_TIMESTAMP),
(1, 'Jane Smith', 'EMP002', 2, 'ROLE002', 'jane.smith@jems.com', '9876543211', '2024-02-01', '456 Oak Avenue, City', true, CURRENT_TIMESTAMP),
(1, 'Bob Johnson', 'EMP003', 1, 'ROLE003', 'bob.johnson@jems.com', '9876543212', '2024-03-10', '789 Pine Road, City', true, CURRENT_TIMESTAMP),
(1, 'Alice Williams', 'EMP004', 3, 'ROLE006', 'alice.williams@jems.com', '9876543213', '2024-04-05', '321 Elm Street, City', true, CURRENT_TIMESTAMP),
(1, 'Charlie Brown', 'EMP005', 2, 'ROLE005', 'charlie.brown@jems.com', '9876543214', '2024-05-12', '654 Maple Drive, City', true, CURRENT_TIMESTAMP),
(1, 'Diana Prince', 'EMP006', 4, 'ROLE004', 'diana.prince@jems.com', '9876543215', '2024-06-20', '987 Cedar Lane, City', true, CURRENT_TIMESTAMP);

-- Insert Customer data
INSERT INTO "Customer" ("customer_code", "customer_name", "mobilenumber", "email_id", "address", "status", "created_at", "updated_at") VALUES
('CUST001', 'ABC Jewelry Store', '9876543215', 'contact@abcjewelry.com', '100 Market Street, City', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('CUST002', 'XYZ Gold Palace', '9876543216', 'info@xyzgold.com', '200 Commerce Road, City', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('CUST003', 'Premium Gems Ltd', '9876543217', 'sales@premiumgems.com', '300 Business Avenue, City', 'inactive', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('CUST004', 'Royal Diamonds', '9876543218', 'info@royaldiamonds.com', '400 Royal Plaza, City', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('CUST005', 'Silver Sparkle', '9876543219', 'contact@silversparkle.com', '500 Silver Street, City', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('CUST006', 'Golden Treasures', '9876543220', 'sales@goldentreasures.com', '600 Gold Avenue, City', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert Vendor data
INSERT INTO "Vendor" ("tenantId", "vendorCode", "vendorName", "vendorType", "contactPerson", "phone", "email", "gstin", "addressLine1", "city", "state", "country", "pincode", "status", "createdAt", "updatedAt") VALUES
(1, 'VEND001', 'Gold Suppliers Inc', 'METAL', 'Mr. Gold', '9876543220', 'contact@goldsuppliers.com', 'GSTIN001', '500 Supplier Street', 'Mumbai', 'Maharashtra', 'India', '400001', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'VEND002', 'Diamond Traders', 'DIAMOND', 'Ms. Diamond', '9876543221', 'info@diamondtraders.com', 'GSTIN002', '600 Trade Avenue', 'Surat', 'Gujarat', 'India', '395001', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'VEND003', 'Stone Merchants', 'STONE', 'Mr. Stone', '9876543222', 'sales@stonemerchants.com', 'GSTIN003', '700 Stone Road', 'Jaipur', 'Rajasthan', 'India', '302001', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'VEND004', 'Alloy Manufacturers', 'ALLOY', 'Mr. Alloy', '9876543223', 'contact@alloymfg.com', 'GSTIN004', '800 Alloy Street', 'Chennai', 'Tamil Nadu', 'India', '600001', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'VEND005', 'Platinum Suppliers', 'METAL', 'Mrs. Platinum', '9876543224', 'info@platinum.com', 'GSTIN005', '900 Platinum Way', 'Delhi', 'Delhi', 'India', '110001', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'VEND006', 'Mixed Materials Corp', 'MIXED', 'Mr. Mixed', '9876543225', 'contact@mixedmaterials.com', 'GSTIN006', '1000 Mixed Boulevard', 'Bangalore', 'Karnataka', 'India', '560001', 'ACTIVE', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- ============================================
-- END OF SCRIPT
-- ============================================
