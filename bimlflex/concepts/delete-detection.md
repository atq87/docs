---
uid: bimlflex-delete-detection
title: BimlFlex Delete Detection
summary: Documentation on BimlFlex delete detection mechanism for detection of hard deleted keys from a source system
---
# BimlFlex Delete Detection

BimlFlex provides a SQL source based delete detection mechanism that allows detection of hard deleted keys from the source system.

This is used in addition to the normal loads of new and changed data from the source.

The Delete Detection is controlled by the following Settings:

* DeleteDetectionEnabled
* DeleteDetectionApplyPsa
* DeleteDetectionApplyRdv

The main **DeleteDetectionEnabled** setting is global and will be applied to all projects.

It is possible to override the global default for specific projects or objects.

Either set the global to `Y` and exclude non-delete projects as needed or set the global to `N` and include the projects/Entities that will use delete detection.

The **DeleteDetectionApply** Settings add post-processing for the detected deletes into the PSA tables and Data Vault Satellites. This allows an end to end processing pipeline for deletes. These steps use SQL post-processing for the target tables and inserts the deleted records.

Enabling delete detection will create new staging tables, by default named `<RecordSourceAsSchema>.<TableName>_DEL`.

The name used is controlled by the following settings:

* `DeleteObjectNamePattern` default value: `@@this_DEL`. That concatenates the `@@this` code for the object name with the `_DEL` suffix
* `DeleteSchemaNamePattern` default value: `@@rs`. The `@@rs` code is the Record Source code from the connection

The Delete Detection process create new load packages that queries the source for all key columns and Integration Key dependent columns.

The delete detection package will load all defined Source and Integration keys from the source into a cache file on the extract machine running the SSIS project. On subsequent runs the package compares the keys in the source with the keys in the cache. If a key is missing from the source compared to what is in the cache, it is identified as a deleted key. These deleted keys are inserted into the delete staging table in the staging database.

The cache files are by default located at:

`C:\BimlFlex\Export\<Name>.raw`

**Note: Make sure `C:\BimlFlex\Export\` folder exists.**

Delete row information is derived through the `RowChangeType` Configuration attribute.

This flag can be customized so that the delete information can be derived as needed. It is possible to reuse a source delete flag for sources that present this in the data set when delete status is known from the source.
