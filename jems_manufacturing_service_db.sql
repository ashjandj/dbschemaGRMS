-- ============================================
-- JEMS Manufacturing Service Database Setup
-- ============================================
-- This file contains PostgreSQL queries for:
-- 1. Database creation
-- 2. Table creation with constraints
-- 3. Sample data insertion
-- ============================================

-- Drop database if exists (use with caution in production)
-- DROP DATABASE IF EXISTS jems_manufacturing;

-- Create database
CREATE DATABASE jems_manufacturing;

-- Connect to the database
-- Note: \c is a psql meta-command. If running in a different SQL client, 
-- you may need to connect to the database manually before running the rest of this script.
-- \c jems_manufacturing;

-- ============================================
-- ENUM Types
-- ============================================

CREATE TYPE "CertificateAuthority" AS ENUM ('GIA', 'IGI', 'HRD', 'OTHER');

-- ============================================
-- TABLES CREATION
-- ============================================

-- AccountingPreference Table
CREATE TABLE "AccountingPreference" (
    "preference_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL UNIQUE,
    "cost_percentage" DOUBLE PRECISION NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL
);

-- UomMaster Table
CREATE TABLE "UomMaster" (
    "uom_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "uom_code" TEXT NOT NULL UNIQUE,
    "uom_name" TEXT NOT NULL,
    "uom_description" TEXT NOT NULL,
    "conversion_rate" DOUBLE PRECISION NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_by" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_by" TEXT,
    "updated_at" TIMESTAMP(3) NOT NULL
);

-- RawMaterial Table
CREATE TABLE "RawMaterial" (
    "item_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "item_code" TEXT NOT NULL UNIQUE,
    "item_name" TEXT NOT NULL,
    "item_description" TEXT NOT NULL,
    "uom_id" INTEGER NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "RawMaterial_uom_id_fkey" FOREIGN KEY ("uom_id") REFERENCES "UomMaster"("uom_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ItemCategory Table (self-referencing)
CREATE TABLE "ItemCategory" (
    "category_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "parent_category_id" INTEGER,
    "description" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "ItemCategory_parent_category_id_fkey" FOREIGN KEY ("parent_category_id") REFERENCES "ItemCategory"("category_id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- DiamondColor Table
CREATE TABLE "DiamondColor" (
    "colour_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "code" TEXT NOT NULL UNIQUE,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL
);

-- DiamondShape Table
CREATE TABLE "DiamondShape" (
    "shape_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "shape_code" TEXT NOT NULL UNIQUE,
    "shape_name" TEXT NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL
);

-- DiamondClarity Table
CREATE TABLE "DiamondClarity" (
    "clarity_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "clarity_code" TEXT NOT NULL UNIQUE,
    "clarity_name" TEXT NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- DiamondSize Table
CREATE TABLE "DiamondSize" (
    "size_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "mm_size" DECIMAL(5,2) NOT NULL,
    "sieve_code" VARCHAR(20) NOT NULL UNIQUE,
    "carat_per_stone" DECIMAL(8,4) NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- DiamondMaster Table
CREATE TABLE "DiamondMaster" (
    "diamond_master_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "diamond_code" TEXT NOT NULL UNIQUE,
    "shape_id" INTEGER NOT NULL,
    "size_id" INTEGER NOT NULL,
    "colour_id" INTEGER NOT NULL,
    "clarity_id" INTEGER NOT NULL,
    "cut_grade" TEXT NOT NULL,
    "certificate_number" TEXT NOT NULL,
    "rate_per_carat" DECIMAL(12,2) NOT NULL,
    "rate_per_piece" DECIMAL(12,2) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "DiamondMaster_shape_id_fkey" FOREIGN KEY ("shape_id") REFERENCES "DiamondShape"("shape_id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "DiamondMaster_size_id_fkey" FOREIGN KEY ("size_id") REFERENCES "DiamondSize"("size_id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "DiamondMaster_colour_id_fkey" FOREIGN KEY ("colour_id") REFERENCES "DiamondColor"("colour_id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "DiamondMaster_clarity_id_fkey" FOREIGN KEY ("clarity_id") REFERENCES "DiamondClarity"("clarity_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- DiamondCut Table
CREATE TABLE "DiamondCut" (
    "cut_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "cut_code" VARCHAR(50) NOT NULL UNIQUE,
    "cut_name" VARCHAR(255) NOT NULL,
    "cut_grade" VARCHAR(50) NOT NULL,
    "polish_grade" VARCHAR(50) NOT NULL,
    "symmetry_grade" VARCHAR(50) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL
);

-- DiamondCertificate Table
CREATE TABLE "DiamondCertificate" (
    "certificate_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "certificate_number" VARCHAR(100) NOT NULL,
    "certificate_authority" "CertificateAuthority" NOT NULL,
    "certificate_file_url" VARCHAR(500),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL
);

-- StoneType Table
CREATE TABLE "StoneType" (
    "stone_type_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "type_code" TEXT NOT NULL UNIQUE,
    "type_name" TEXT NOT NULL,
    "description" TEXT,
    "is_precious" BOOLEAN NOT NULL DEFAULT false,
    "is_active" BOOLEAN NOT NULL DEFAULT true
);

-- StoneColour Table
CREATE TABLE "StoneColour" (
    "colour_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "colour_code" TEXT NOT NULL UNIQUE,
    "colour_name" TEXT NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL
);

-- StoneShape Table
CREATE TABLE "StoneShape" (
    "shape_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "shape_code" TEXT NOT NULL UNIQUE,
    "shape_name" TEXT NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL
);

-- StoneQuality Table
CREATE TABLE "StoneQuality" (
    "quality_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "quality_code" TEXT NOT NULL UNIQUE,
    "quality_name" TEXT NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL
);

-- StoneSize Table
CREATE TABLE "StoneSize" (
    "size_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "size_mm" DECIMAL(6,2) NOT NULL,
    "size_calibrated" VARCHAR(50),
    "carat_per_stone" DECIMAL(10,4),
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL
);

-- StoneMaster Table
CREATE TABLE "StoneMaster" (
    "stone_master_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "stone_code" VARCHAR(100) NOT NULL UNIQUE,
    "stone_type_id" INTEGER NOT NULL,
    "shape_id" INTEGER NOT NULL,
    "size_id" INTEGER NOT NULL,
    "colour_id" INTEGER NOT NULL,
    "quality_id" INTEGER NOT NULL,
    "carat_per_stone" DECIMAL(10,4),
    "rate_per_carat" DECIMAL(12,2),
    "rate_per_piece" DECIMAL(12,2),
    "is_precious" BOOLEAN NOT NULL DEFAULT false,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "StoneMaster_stone_type_id_fkey" FOREIGN KEY ("stone_type_id") REFERENCES "StoneType"("stone_type_id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "StoneMaster_shape_id_fkey" FOREIGN KEY ("shape_id") REFERENCES "StoneShape"("shape_id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "StoneMaster_size_id_fkey" FOREIGN KEY ("size_id") REFERENCES "StoneSize"("size_id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "StoneMaster_colour_id_fkey" FOREIGN KEY ("colour_id") REFERENCES "StoneColour"("colour_id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "StoneMaster_quality_id_fkey" FOREIGN KEY ("quality_id") REFERENCES "StoneQuality"("quality_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- MetalColour Table
CREATE TABLE "MetalColour" (
    "metal_colour_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "colour_code" TEXT NOT NULL UNIQUE,
    "colour_name" TEXT NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL
);

-- MetalPurity Table
CREATE TABLE "MetalPurity" (
    "purity_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "purity_name" VARCHAR(50) NOT NULL,
    "purity_code" VARCHAR(20) NOT NULL UNIQUE,
    "karat_value" DECIMAL(5,2),
    "percentage_value" DECIMAL(6,3),
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL
);

-- AlloysRecipe Table
CREATE TABLE "AlloysRecipe" (
    "alloy_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "recipe_name" VARCHAR(255) NOT NULL,
    "recipe_code" VARCHAR(50) NOT NULL UNIQUE,
    "colour_id" INTEGER NOT NULL,
    "karat_value" DECIMAL(5,2),
    "target_purity" DECIMAL(6,3),
    "expected_wastage" DECIMAL(6,3),
    "input_type" DECIMAL(6,3),
    "total_percentage" DECIMAL(6,3),
    "total_weight" DECIMAL(12,3),
    "description" TEXT,
    "created_by" CHAR(36),
    "updated_by" CHAR(36),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    CONSTRAINT "AlloysRecipe_colour_id_fkey" FOREIGN KEY ("colour_id") REFERENCES "MetalColour"("metal_colour_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- AlloyComponent Table
CREATE TABLE "AlloyComponent" (
    "component_id" SERIAL PRIMARY KEY,
    "alloy_id" INTEGER NOT NULL,
    "tenant_id" INTEGER NOT NULL,
    "percentage_value" DECIMAL(6,3),
    "weight_value" DECIMAL(12,3),
    "display_order" INTEGER NOT NULL,
    "material_source_type" VARCHAR(50) NOT NULL,
    "raw_material_id" INTEGER,
    "component_alloy_id" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "AlloyComponent_alloy_id_fkey" FOREIGN KEY ("alloy_id") REFERENCES "AlloysRecipe"("alloy_id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "AlloyComponent_raw_material_id_fkey" FOREIGN KEY ("raw_material_id") REFERENCES "RawMaterial"("item_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ManufacturingBrand Table
CREATE TABLE "ManufacturingBrand" (
    "id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER,
    "brand_code" TEXT NOT NULL UNIQUE,
    "brand_name" TEXT NOT NULL,
    "description" TEXT,
    "status" TEXT NOT NULL DEFAULT 'active',
    "logo_url" TEXT,
    "created_by" TEXT,
    "updated_by" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ProductMaster Table
CREATE TABLE "ProductMaster" (
    "product_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "design_number" VARCHAR(100) NOT NULL,
    "product_name" VARCHAR(200) NOT NULL,
    "category_id" INTEGER NOT NULL,
    "brand_id" INTEGER,
    "net_weight" DECIMAL(10,3),
    "total_metal_weight" DECIMAL(12,3),
    "total_diamond_weight" DECIMAL(12,3),
    "total_diamond_count" INTEGER,
    "total_stone_weight" DECIMAL(12,3),
    "total_stone_count" INTEGER,
    "hsn_code" VARCHAR(20),
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_by" TEXT,
    "updated_by" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "ProductMaster_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "ItemCategory"("category_id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "ProductMaster_brand_id_fkey" FOREIGN KEY ("brand_id") REFERENCES "ManufacturingBrand"("id") ON DELETE SET NULL ON UPDATE CASCADE
);

-- ProductMetal Table
CREATE TABLE "ProductMetal" (
    "product_metal_id" SERIAL PRIMARY KEY,
    "product_id" INTEGER NOT NULL,
    "alloy_id" INTEGER,
    "raw_material_id" INTEGER,
    "metal_colour_id" INTEGER,
    "metal_purity_id" INTEGER,
    "metal_weight" DECIMAL(12,3) NOT NULL,
    "tenant_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "ProductMetal_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "ProductMaster"("product_id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "ProductMetal_raw_material_id_fkey" FOREIGN KEY ("raw_material_id") REFERENCES "RawMaterial"("item_id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "ProductMetal_alloy_id_fkey" FOREIGN KEY ("alloy_id") REFERENCES "AlloysRecipe"("alloy_id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "ProductMetal_metal_purity_id_fkey" FOREIGN KEY ("metal_purity_id") REFERENCES "MetalPurity"("purity_id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "ProductMetal_metal_colour_id_fkey" FOREIGN KEY ("metal_colour_id") REFERENCES "MetalColour"("metal_colour_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ProductDiamonds Table
CREATE TABLE "ProductDiamonds" (
    "product_diamond_id" SERIAL PRIMARY KEY,
    "product_id" INTEGER NOT NULL,
    "diamond_master_id" INTEGER,
    "pieces" INTEGER NOT NULL,
    "total_carat" DECIMAL(10,4) NOT NULL,
    "total_value" DECIMAL(12,2) NOT NULL,
    "tenant_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "ProductDiamonds_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "ProductMaster"("product_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ProductStones Table
CREATE TABLE "ProductStones" (
    "product_stone_id" SERIAL PRIMARY KEY,
    "product_id" INTEGER NOT NULL,
    "stone_master_id" INTEGER NOT NULL,
    "pcs" INTEGER NOT NULL,
    "total_carat" DECIMAL(10,4) NOT NULL,
    "total_value" DECIMAL(12,2) NOT NULL,
    "tenant_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "ProductStones_product_id_fkey" FOREIGN KEY ("product_id") REFERENCES "ProductMaster"("product_id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "ProductStones_stone_master_id_fkey" FOREIGN KEY ("stone_master_id") REFERENCES "StoneMaster"("stone_master_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- orderType Table
CREATE TABLE "orderType" (
    "order_type_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "code" TEXT NOT NULL UNIQUE,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- OrderHeading Table
-- NOTE: customer_id references Customer table in jems_admin database (cross-database reference)
-- PostgreSQL does not support foreign keys across databases. This relationship must be
-- enforced at the application level or through database federation/views.
CREATE TABLE "OrderHeading" (
    "order_id" SERIAL PRIMARY KEY,
    "order_type" TEXT NOT NULL,
    "customer_id" TEXT NOT NULL,
    "expected_delivery_date" TIMESTAMP(3) NOT NULL,
    "order_no" TEXT NOT NULL,
    "remarks" TEXT,
    "total_order_value" DOUBLE PRECISION,
    "tenant_id" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- OrderLineItems Table
CREATE TABLE "OrderLineItems" (
    "order_item_id" SERIAL PRIMARY KEY,
    "order_id" INTEGER NOT NULL,
    "tenant_id" INTEGER NOT NULL,
    "category_id" INTEGER NOT NULL,
    "reference_image_url" TEXT,
    "item_name" TEXT NOT NULL,
    "sku_reference" TEXT,
    "quantity" INTEGER NOT NULL,
    "making_charge" DECIMAL(12,2) NOT NULL,
    "material_cost" DECIMAL(12,2) NOT NULL,
    "total_cost" DECIMAL(12,2) NOT NULL,
    "remarks" TEXT,
    CONSTRAINT "OrderLineItems_order_id_fkey" FOREIGN KEY ("order_id") REFERENCES "OrderHeading"("order_id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "OrderLineItems_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "ItemCategory"("category_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- StockAdjustment Table
-- NOTE: created_by references Employee table in jems_admin database (cross-database reference)
-- PostgreSQL does not support foreign keys across databases. This relationship must be
-- enforced at the application level or through database federation/views.
CREATE TABLE "StockAdjustment" (
    "adjustment_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "adjustment_date" DATE NOT NULL,
    "reason" VARCHAR(255),
    "remarks" TEXT,
    "created_by" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- AlloyCreation Table
CREATE TABLE "AlloyCreation" (
    "alloy_creation_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "recipe_id" INTEGER NOT NULL,
    "new_batch" BOOLEAN NOT NULL,
    "purity" DECIMAL(6,3) NOT NULL,
    "input_weight" DECIMAL(12,3) NOT NULL,
    "recipe_name" VARCHAR(255) NOT NULL,
    "batch_number" VARCHAR(50) NOT NULL,
    "expected_yield" DECIMAL(12,3) NOT NULL,
    "actual_yield" DECIMAL(12,3),
    "wastage" DECIMAL(12,3),
    "status" VARCHAR(20) NOT NULL,
    "completed_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "AlloyCreation_recipe_id_fkey" FOREIGN KEY ("recipe_id") REFERENCES "AlloysRecipe"("alloy_id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- StockEntry Table
-- NOTE: vendor_id references Vendor table in jems_admin database (cross-database reference)
-- NOTE: created_by references Employee table in jems_admin database (cross-database reference)
-- PostgreSQL does not support foreign keys across databases. These relationships must be
-- enforced at the application level or through database federation/views.
CREATE TABLE "StockEntry" (
    "stock_entry_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "vendor_id" INTEGER NOT NULL,
    "invoice_ref_no" VARCHAR(50),
    "entry_date" DATE NOT NULL,
    "remarks" TEXT,
    "created_by" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- StockLot Table (includes alloy_recipe_id for relation) - Created before AlloyCreationItem and BatchReservation
CREATE TABLE "StockLot" (
    "lot_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "lot_no" VARCHAR(50) NOT NULL,
    "diamond_master_id" INTEGER,
    "stone_master_id" INTEGER,
    "raw_material_id" INTEGER,
    "alloy_creation_id" INTEGER,
    "alloy_recipe_id" INTEGER,
    "quantity_available_weight" DECIMAL(12,3),
    "quantity_available_pieces" INTEGER,
    "quantity_on_hand_weight" DECIMAL(12,3),
    "quantity_on_hand_pieces" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "StockLot_alloy_creation_id_fkey" FOREIGN KEY ("alloy_creation_id") REFERENCES "AlloyCreation"("alloy_creation_id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "StockLot_diamond_master_id_fkey" FOREIGN KEY ("diamond_master_id") REFERENCES "DiamondMaster"("diamond_master_id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "StockLot_stone_master_id_fkey" FOREIGN KEY ("stone_master_id") REFERENCES "StoneMaster"("stone_master_id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "StockLot_alloy_recipe_id_fkey" FOREIGN KEY ("alloy_recipe_id") REFERENCES "AlloysRecipe"("alloy_id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "StockLot_raw_material_id_fkey" FOREIGN KEY ("raw_material_id") REFERENCES "RawMaterial"("item_id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- AlloyCreationItem Table (created after StockLot)
CREATE TABLE "AlloyCreationItem" (
    "creation_item_id" SERIAL PRIMARY KEY,
    "alloy_creation_id" INTEGER NOT NULL,
    "tenant_id" INTEGER NOT NULL,
    "source_lot_id" INTEGER NOT NULL,
    "required_weight" DECIMAL(12,3) NOT NULL,
    "actual_used_weight" DECIMAL(12,3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "AlloyCreationItem_alloy_creation_id_fkey" FOREIGN KEY ("alloy_creation_id") REFERENCES "AlloyCreation"("alloy_creation_id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "AlloyCreationItem_source_lot_id_fkey" FOREIGN KEY ("source_lot_id") REFERENCES "StockLot"("lot_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- BatchReservation Table (created after StockLot)
CREATE TABLE "BatchReservation" (
    "reservation_id" SERIAL PRIMARY KEY,
    "tenant_id" INTEGER NOT NULL,
    "alloy_creation_id" INTEGER NOT NULL,
    "lot_id" INTEGER NOT NULL,
    "reserved_weight" DECIMAL(12,3) NOT NULL,
    "status" VARCHAR(20) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,
    CONSTRAINT "BatchReservation_alloy_creation_id_fkey" FOREIGN KEY ("alloy_creation_id") REFERENCES "AlloyCreation"("alloy_creation_id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "BatchReservation_lot_id_fkey" FOREIGN KEY ("lot_id") REFERENCES "StockLot"("lot_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- StockEntryItem Table
CREATE TABLE "StockEntryItem" (
    "entry_item_id" SERIAL PRIMARY KEY,
    "stock_entry_id" INTEGER NOT NULL,
    "lot_id" INTEGER NOT NULL,
    "weight" DECIMAL(12,3),
    "pieces" INTEGER,
    "rate_per_weight" DECIMAL(12,2),
    "rate_per_piece" DECIMAL(12,2),
    "line_amount" DECIMAL(14,2) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "StockEntryItem_stock_entry_id_fkey" FOREIGN KEY ("stock_entry_id") REFERENCES "StockEntry"("stock_entry_id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "StockEntryItem_lot_id_fkey" FOREIGN KEY ("lot_id") REFERENCES "StockLot"("lot_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- StockAdjustmentItem Table
CREATE TABLE "StockAdjustmentItem" (
    "adjustment_item_id" SERIAL PRIMARY KEY,
    "adjustment_id" INTEGER NOT NULL,
    "lot_id" INTEGER NOT NULL,
    "current_weight" DECIMAL(12,3),
    "current_pieces" INTEGER,
    "adjustment_weight" DECIMAL(12,3),
    "adjustment_pieces" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "StockAdjustmentItem_adjustment_id_fkey" FOREIGN KEY ("adjustment_id") REFERENCES "StockAdjustment"("adjustment_id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "StockAdjustmentItem_lot_id_fkey" FOREIGN KEY ("lot_id") REFERENCES "StockLot"("lot_id") ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX "RawMaterial_tenant_id_idx" ON "RawMaterial"("tenant_id");
CREATE INDEX "RawMaterial_uom_id_idx" ON "RawMaterial"("uom_id");
CREATE INDEX "ItemCategory_tenant_id_idx" ON "ItemCategory"("tenant_id");
CREATE INDEX "DiamondMaster_tenant_id_idx" ON "DiamondMaster"("tenant_id");
CREATE INDEX "StockLot_tenant_id_idx" ON "StockLot"("tenant_id");

-- ============================================
-- SAMPLE DATA INSERTION
-- ============================================

-- Insert UomMaster data
INSERT INTO "UomMaster" ("tenant_id", "uom_code", "uom_name", "uom_description", "conversion_rate", "is_active", "created_by", "created_at", "updated_at") VALUES
(1, 'GRAM', 'Gram', 'Weight in grams', 1.0, true, 'system', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'KG', 'Kilogram', 'Weight in kilograms', 1000.0, true, 'system', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'PCS', 'Pieces', 'Count in pieces', 1.0, true, 'system', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'CARAT', 'Carat', 'Weight in carats', 0.2, true, 'system', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'OUNCE', 'Ounce', 'Weight in ounces', 28.35, true, 'system', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'TOLA', 'Tola', 'Traditional weight unit', 11.66, true, 'system', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert RawMaterial data
INSERT INTO "RawMaterial" ("tenant_id", "item_code", "item_name", "item_description", "uom_id", "is_active", "created_at") VALUES
(1, 'RM001', '24K Gold', 'Pure 24 karat gold', 1, true, CURRENT_TIMESTAMP),
(1, 'RM002', '22K Gold', '22 karat gold', 1, true, CURRENT_TIMESTAMP),
(1, 'RM003', 'Silver', 'Pure silver', 1, true, CURRENT_TIMESTAMP),
(1, 'RM004', 'Platinum', 'Pure platinum', 1, true, CURRENT_TIMESTAMP),
(1, 'RM005', '18K Gold', '18 karat gold', 1, true, CURRENT_TIMESTAMP),
(1, 'RM006', 'Palladium', 'Pure palladium', 1, true, CURRENT_TIMESTAMP);

-- Insert ItemCategory data
INSERT INTO "ItemCategory" ("tenant_id", "name", "parent_category_id", "description", "is_active", "created_at") VALUES
(1, 'Rings', NULL, 'Ring category', true, CURRENT_TIMESTAMP),
(1, 'Necklaces', NULL, 'Necklace category', true, CURRENT_TIMESTAMP),
(1, 'Earrings', NULL, 'Earring category', true, CURRENT_TIMESTAMP),
(1, 'Bracelets', NULL, 'Bracelet category', true, CURRENT_TIMESTAMP),
(1, 'Bangles', NULL, 'Bangle category', true, CURRENT_TIMESTAMP),
(1, 'Pendants', NULL, 'Pendant category', true, CURRENT_TIMESTAMP);

-- Insert DiamondColor data
INSERT INTO "DiamondColor" ("tenant_id", "name", "code", "description", "is_active", "created_at", "updated_at") VALUES
(1, 'D', 'D', 'Colorless', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'E', 'E', 'Near Colorless', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'F', 'F', 'Near Colorless', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'G', 'G', 'Near Colorless', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'H', 'H', 'Near Colorless', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'I', 'I', 'Near Colorless', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'J', 'J', 'Near Colorless', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert DiamondShape data
INSERT INTO "DiamondShape" ("tenant_id", "shape_code", "shape_name", "description", "is_active", "created_at", "updated_at") VALUES
(1, 'ROUND', 'Round', 'Round brilliant cut', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'PRINCESS', 'Princess', 'Princess cut', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'EMERALD', 'Emerald', 'Emerald cut', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'CUSHION', 'Cushion', 'Cushion cut', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'OVAL', 'Oval', 'Oval cut', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'PEAR', 'Pear', 'Pear cut', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'MARQUISE', 'Marquise', 'Marquise cut', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert DiamondClarity data
INSERT INTO "DiamondClarity" ("tenant_id", "clarity_code", "clarity_name", "description", "is_active", "created_at") VALUES
(1, 'FL', 'Flawless', 'Flawless clarity', true, CURRENT_TIMESTAMP),
(1, 'IF', 'Internally Flawless', 'Internally flawless', true, CURRENT_TIMESTAMP),
(1, 'VVS1', 'VVS1', 'Very very slightly included 1', true, CURRENT_TIMESTAMP),
(1, 'VVS2', 'VVS2', 'Very very slightly included 2', true, CURRENT_TIMESTAMP),
(1, 'VS1', 'VS1', 'Very slightly included 1', true, CURRENT_TIMESTAMP),
(1, 'VS2', 'VS2', 'Very slightly included 2', true, CURRENT_TIMESTAMP),
(1, 'SI1', 'SI1', 'Slightly included 1', true, CURRENT_TIMESTAMP);

-- Insert DiamondSize data
INSERT INTO "DiamondSize" ("tenant_id", "mm_size", "sieve_code", "carat_per_stone", "description", "is_active", "created_at") VALUES
(1, 1.00, 'SIEVE1', 0.005, '1mm diamond', true, CURRENT_TIMESTAMP),
(1, 2.00, 'SIEVE2', 0.040, '2mm diamond', true, CURRENT_TIMESTAMP),
(1, 3.00, 'SIEVE3', 0.135, '3mm diamond', true, CURRENT_TIMESTAMP),
(1, 4.00, 'SIEVE4', 0.320, '4mm diamond', true, CURRENT_TIMESTAMP),
(1, 5.00, 'SIEVE5', 0.625, '5mm diamond', true, CURRENT_TIMESTAMP),
(1, 6.00, 'SIEVE6', 1.080, '6mm diamond', true, CURRENT_TIMESTAMP);

-- Insert DiamondMaster data
INSERT INTO "DiamondMaster" ("tenant_id", "diamond_code", "shape_id", "size_id", "colour_id", "clarity_id", "cut_grade", "certificate_number", "rate_per_carat", "rate_per_piece", "is_active", "created_at", "updated_at") VALUES
(1, 'DM001', 1, 1, 1, 1, 'EX', 'CERT001', 50000.00, 250.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'DM002', 2, 2, 2, 2, 'VG', 'CERT002', 45000.00, 1800.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'DM003', 1, 3, 3, 3, 'EX', 'CERT003', 42000.00, 5670.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'DM004', 4, 4, 4, 4, 'VG', 'CERT004', 38000.00, 12160.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'DM005', 3, 2, 2, 2, 'EX', 'CERT005', 44000.00, 1760.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'DM006', 5, 5, 5, 5, 'VG', 'CERT006', 35000.00, 21875.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert StoneType data
INSERT INTO "StoneType" ("tenant_id", "type_code", "type_name", "description", "is_precious", "is_active") VALUES
(1, 'RUBY', 'Ruby', 'Ruby gemstone', true, true),
(1, 'EMERALD', 'Emerald', 'Emerald gemstone', true, true),
(1, 'SAPPHIRE', 'Sapphire', 'Sapphire gemstone', true, true),
(1, 'PEARL', 'Pearl', 'Pearl gemstone', true, true),
(1, 'GARNET', 'Garnet', 'Garnet gemstone', false, true),
(1, 'AMETHYST', 'Amethyst', 'Amethyst gemstone', false, true),
(1, 'CITRINE', 'Citrine', 'Citrine gemstone', false, true);

-- Insert StoneColour data
INSERT INTO "StoneColour" ("tenant_id", "colour_code", "colour_name", "description", "is_active", "created_at", "updated_at") VALUES
(1, 'RED', 'Red', 'Red color', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'GREEN', 'Green', 'Green color', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'BLUE', 'Blue', 'Blue color', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'WHITE', 'White', 'White color', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'PURPLE', 'Purple', 'Purple color', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'YELLOW', 'Yellow', 'Yellow color', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'PINK', 'Pink', 'Pink color', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert StoneShape data
INSERT INTO "StoneShape" ("tenant_id", "shape_code", "shape_name", "description", "is_active", "created_at", "updated_at") VALUES
(1, 'ROUND', 'Round', 'Round shape', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'OVAL', 'Oval', 'Oval shape', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'PEAR', 'Pear', 'Pear shape', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'CUSHION', 'Cushion', 'Cushion shape', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'PRINCESS', 'Princess', 'Princess shape', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'HEART', 'Heart', 'Heart shape', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert StoneQuality data
INSERT INTO "StoneQuality" ("tenant_id", "quality_code", "quality_name", "description", "is_active", "created_at", "updated_at") VALUES
(1, 'AAA', 'AAA', 'AAA quality', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'AA', 'AA', 'AA quality', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'A', 'A', 'A quality', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'AA+', 'AA+', 'AA Plus quality', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'A+', 'A+', 'A Plus quality', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'B', 'B', 'B quality', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert StoneSize data
INSERT INTO "StoneSize" ("tenant_id", "size_mm", "size_calibrated", "carat_per_stone", "description", "is_active", "created_at", "updated_at") VALUES
(1, 3.00, '3MM', 0.15, '3mm stone', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 4.00, '4MM', 0.35, '4mm stone', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 5.00, '5MM', 0.68, '5mm stone', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 6.00, '6MM', 1.18, '6mm stone', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 7.00, '7MM', 1.88, '7mm stone', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 8.00, '8MM', 2.75, '8mm stone', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert StoneMaster data
INSERT INTO "StoneMaster" ("tenant_id", "stone_code", "stone_type_id", "shape_id", "size_id", "colour_id", "quality_id", "carat_per_stone", "rate_per_carat", "rate_per_piece", "is_precious", "is_active", "created_at", "updated_at") VALUES
(1, 'ST001', 1, 1, 1, 1, 1, 0.15, 8000.00, 1200.00, true, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'ST002', 2, 2, 2, 2, 1, 0.35, 12000.00, 4200.00, true, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'ST003', 3, 3, 3, 3, 1, 0.68, 15000.00, 10200.00, true, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'ST004', 4, 1, 2, 4, 2, 0.35, 5000.00, 1750.00, true, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'ST005', 5, 4, 4, 1, 3, 1.18, 3000.00, 3540.00, false, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'ST006', 6, 5, 5, 5, 2, 1.88, 2500.00, 4700.00, false, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert MetalColour data
INSERT INTO "MetalColour" ("tenant_id", "colour_code", "colour_name", "description", "is_active", "created_at", "updated_at") VALUES
(1, 'YELLOW', 'Yellow Gold', 'Yellow gold color', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'WHITE', 'White Gold', 'White gold color', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'ROSE', 'Rose Gold', 'Rose gold color', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert MetalPurity data
INSERT INTO "MetalPurity" ("tenant_id", "purity_name", "purity_code", "karat_value", "percentage_value", "description", "is_active", "created_at", "updated_at") VALUES
(1, '24K', '24K', 24.00, 99.90, '24 karat purity', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, '22K', '22K', 22.00, 91.67, '22 karat purity', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, '18K', '18K', 18.00, 75.00, '18 karat purity', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, '14K', '14K', 14.00, 58.33, '14 karat purity', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, '10K', '10K', 10.00, 41.67, '10 karat purity', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, '925', '925', NULL, 92.50, 'Sterling silver 925', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert AlloysRecipe data
INSERT INTO "AlloysRecipe" ("tenant_id", "recipe_name", "recipe_code", "colour_id", "karat_value", "target_purity", "expected_wastage", "total_percentage", "is_active", "created_at", "updated_at") VALUES
(1, '22K Yellow Gold', 'REC001', 1, 22.00, 91.67, 2.00, 100.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, '18K White Gold', 'REC002', 2, 18.00, 75.00, 2.50, 100.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, '18K Rose Gold', 'REC003', 3, 18.00, 75.00, 2.00, 100.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, '14K Yellow Gold', 'REC004', 1, 14.00, 58.33, 2.25, 100.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, '14K White Gold', 'REC005', 2, 14.00, 58.33, 2.75, 100.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, '22K Rose Gold', 'REC006', 3, 22.00, 91.67, 2.10, 100.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert ManufacturingBrand data
INSERT INTO "ManufacturingBrand" ("tenant_id", "brand_code", "brand_name", "description", "status", "createdAt", "updatedAt") VALUES
(1, 'BRAND001', 'Premium Collection', 'Premium jewelry brand', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'BRAND002', 'Classic Collection', 'Classic jewelry brand', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'BRAND003', 'Royal Collection', 'Royal jewelry brand', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'BRAND004', 'Modern Collection', 'Modern jewelry brand', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'BRAND005', 'Heritage Collection', 'Heritage jewelry brand', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'BRAND006', 'Exclusive Collection', 'Exclusive jewelry brand', 'active', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert ProductMaster data
INSERT INTO "ProductMaster" ("tenant_id", "design_number", "product_name", "category_id", "brand_id", "net_weight", "total_metal_weight", "is_active", "created_at", "updated_at") VALUES
(1, 'DES001', 'Gold Ring - Classic', 1, 1, 5.500, 5.500, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'DES002', 'Diamond Necklace', 2, 1, 15.250, 15.000, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'DES003', 'Ruby Earrings', 3, 2, 8.750, 8.500, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'DES004', 'Platinum Bracelet', 4, 1, 12.000, 12.000, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'DES005', 'Emerald Pendant', 6, 3, 6.250, 6.000, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'DES006', 'Gold Bangle Set', 5, 2, 45.500, 45.000, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert orderType data
INSERT INTO "orderType" ("tenant_id", "code", "name", "description", "is_active", "created_at") VALUES
(1, 'ORD001', 'Custom Order', 'Custom jewelry order', true, CURRENT_TIMESTAMP),
(1, 'ORD002', 'Standard Order', 'Standard jewelry order', true, CURRENT_TIMESTAMP),
(1, 'ORD003', 'Repair Order', 'Jewelry repair order', true, CURRENT_TIMESTAMP),
(1, 'ORD004', 'Resize Order', 'Ring resize order', true, CURRENT_TIMESTAMP),
(1, 'ORD005', 'Engraving Order', 'Engraving service order', true, CURRENT_TIMESTAMP),
(1, 'ORD006', 'Bulk Order', 'Bulk jewelry order', true, CURRENT_TIMESTAMP);

-- Insert AccountingPreference data
INSERT INTO "AccountingPreference" ("tenant_id", "cost_percentage", "created_at", "updated_at") VALUES
(1, 15.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- ============================================
-- END OF SCRIPT
-- ============================================
