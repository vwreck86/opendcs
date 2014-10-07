------------------------------------------------------------------------------
-- CWMS DECODES and CCP Database Schema 
------------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- This software was written by Cove Software, LLC ("COVE") under contract 
-- to the United States Government. 
-- No warranty is provided or implied other than specific contractual terms
-- between COVE and the U.S. Government
-- 
-- Copyright 2014 U.S. Army Corps of Engineers, Hydrologic Engineering Center.
-- All rights reserved.
-----------------------------------------------------------------------------

CREATE TABLE CONFIGSENSOR
(
	CONFIGID NUMBER(18) NOT NULL,
	-- Ordinal number of this sensor within this configuration
	SENSORNUMBER INT NOT NULL,
	SENSORNAME VARCHAR2(64) NOT NULL,
	RECORDINGMODE CHAR NOT NULL,
	-- # seconds between samples taken on the platform.
	RECORDINGINTERVAL INT,
	-- Second of day of first sample taken on the platform.
	-- Used for auto time-tagging.
	TIMEOFFIRSTSAMPLE INT,
	-- legacy not used
	EQUIPMENTID NUMBER(18),
	-- If not null, values below this are tossed.
	ABSOLUTEMIN DOUBLE PRECISION,
	-- If not null, values above this are tossed.
	ABSOLUTEMAX DOUBLE PRECISION,
	-- Used by USGS
	STAT_CD VARCHAR2(5),
	PRIMARY KEY (CONFIGID, SENSORNUMBER)
) &TBL_SPACE_SPEC;


CREATE TABLE CONFIGSENSORDATATYPE
(
	CONFIGID NUMBER(18) NOT NULL,
	-- Ordinal number of this sensor within this configuration
	SENSORNUMBER INT NOT NULL,
	DATATYPEID NUMBER(18) NOT NULL,
	PRIMARY KEY (CONFIGID, SENSORNUMBER, DATATYPEID)
) &TBL_SPACE_SPEC;


CREATE TABLE CONFIGSENSORPROPERTY
(
	CONFIGID NUMBER(18) NOT NULL,
	-- Ordinal number of this sensor within this configuration
	SENSORNUMBER INT NOT NULL,
	PROP_NAME VARCHAR2(24) NOT NULL,
	PROP_VALUE VARCHAR2(240) NOT NULL,
	PRIMARY KEY (CONFIGID, SENSORNUMBER, PROP_NAME)
) &TBL_SPACE_SPEC;


CREATE TABLE CP_ALGORITHM
(
	ALGORITHM_ID NUMBER(18) NOT NULL,
	ALGORITHM_NAME VARCHAR2(64) NOT NULL,
	-- May be null for pseudo or placeholder algorithms
	EXEC_CLASS VARCHAR2(240),
	CMMNT VARCHAR2(1000),
	db_office_code integer default &dflt_office_code,
	PRIMARY KEY (ALGORITHM_ID),
	CONSTRAINT ALGORITHM_NAME_UNIQUE UNIQUE(ALGORITHM_NAME, db_office_code)
) &TBL_SPACE_SPEC;


CREATE TABLE CP_ALGO_PROPERTY
(
	ALGORITHM_ID NUMBER(18) NOT NULL,
	PROP_NAME VARCHAR2(48) NOT NULL,
	-- In oracle an empty string is the same as null, so we can't use
	-- NOT NULL on PROP_VALUE here.
	PROP_VALUE VARCHAR2(240),
	CONSTRAINT algo_prop_unique UNIQUE (ALGORITHM_ID, PROP_NAME)
) &TBL_SPACE_SPEC;


CREATE TABLE CP_ALGO_TS_PARM
(
	ALGORITHM_ID NUMBER(18) NOT NULL,
	ALGO_ROLE_NAME VARCHAR2(24) NOT NULL,
	PARM_TYPE VARCHAR2(24) NOT NULL,
	CONSTRAINT algo_role_unique UNIQUE (ALGORITHM_ID, ALGO_ROLE_NAME)
) &TBL_SPACE_SPEC;

-- This table holds the XML definition for a composite computation diagram in the GUI.
-- Concatenate all elements for a given composite comp by part_number to form the entire XML.
-- The XML depends on the SQL composite/member relations. You cannot alter one without altering the other.
CREATE TABLE CP_COMPOSITE_DIAGRAM
(
    COMPOSITE_COMPUTATION_ID INT NOT NULL,
    BLOCK_NUM INT NOT NULL,
    DIAGRAM_XML VARCHAR2(4000) NOT NULL,
    PRIMARY KEY (COMPOSITE_COMPUTATION_ID, BLOCK_NUM)
) &TBL_SPACE_SPEC;

-- This table relates a composite computation to its member component computations.
-- A composite has multiple components, each with a different execution order.
CREATE TABLE CP_COMPOSITE_MEMBER
(
    COMPOSITE_COMPUTATION_ID INT NOT NULL,
    -- Determines the execution order of the component.
    EXEC_ORDER INT NOT NULL,
    COMPONENT_COMPUTATION_ID INT NOT NULL,
    PRIMARY KEY (COMPOSITE_COMPUTATION_ID, EXEC_ORDER)
) &TBL_SPACE_SPEC;

CREATE TABLE CP_COMPUTATION
(
	COMPUTATION_ID NUMBER(18) NOT NULL,
	COMPUTATION_NAME VARCHAR2(64) NOT NULL,
	ALGORITHM_ID NUMBER(18),
	CMMNT VARCHAR2(1000),
	LOADING_APPLICATION_ID NUMBER(18),
	DATE_TIME_LOADED date NOT NULL,
	ENABLED VARCHAR2(5) NOT NULL,
	-- Null means goes to the beggining of time.
	EFFECTIVE_START_DATE_TIME date,
	-- Null means never expires
	EFFECTIVE_END_DATE_TIME date,
	GROUP_ID NUMBER(18),
	db_office_code integer default &dflt_office_code,
	PRIMARY KEY (COMPUTATION_ID),
	CONSTRAINT COMPUTATION_NAME_UNIQUE UNIQUE(COMPUTATION_NAME, db_office_code)
) &TBL_SPACE_SPEC;


-- An entry in this table asserts that a time series is an input to a given computation.
-- The computation processor uses it to determine which computations to execute for a given input.
CREATE TABLE CP_COMP_DEPENDS
(
	TS_ID NUMBER(18) NOT NULL,
	COMPUTATION_ID NUMBER(18) NOT NULL,
	PRIMARY KEY (TS_ID, COMPUTATION_ID)
) &TBL_SPACE_SPEC;


CREATE TABLE CP_COMP_DEPENDS_SCRATCHPAD
(
	TS_ID NUMBER(18) NOT NULL,
	COMPUTATION_ID NUMBER(18) NOT NULL,
	PRIMARY KEY (TS_ID, COMPUTATION_ID)
) &TBL_SPACE_SPEC;


CREATE TABLE CP_COMP_PROC_LOCK
(
	LOADING_APPLICATION_ID NUMBER(18) NOT NULL,
	PID INT NOT NULL,
	HOSTNAME VARCHAR2(400) NOT NULL,
	HEARTBEAT date NOT NULL,
	CUR_STATUS VARCHAR2(64) NOT NULL,
	CONSTRAINT LOADING_APPLICATION_ID_UNIQUE UNIQUE(LOADING_APPLICATION_ID)
) &TBL_SPACE_SPEC;


CREATE TABLE CP_COMP_PROPERTY
(
	COMPUTATION_ID NUMBER(18) NOT NULL,
	PROP_NAME VARCHAR2(48) NOT NULL,
	PROP_VALUE VARCHAR2(240) NOT NULL,
	PRIMARY KEY (COMPUTATION_ID, PROP_NAME)
) &TBL_SPACE_SPEC;


create table cp_comp_tasklist
(
    record_num integer not null,
    loading_application_id integer not null,
    site_datatype_id integer not null,
    interval varchar(24),                      -- not req'd by some dbs
    table_selector varchar(80),                -- store "parmtype.duration.version"
    value float,                               -- not req'd for deleted data
    date_time_loaded date not null,
    start_date_time date not null,
    delete_flag varchar(1) default 'N',        -- 'N': not delete; 'Y': TS data deleted; 'U': TS code changed
    model_run_id integer default null,         -- will be null for real data
    flags integer not null,
    source_id integer,                         -- may be null
    fail_time date default null,               -- may be null
    quality_code integer,                      -- add this field for using cwms DB
    unit_id varchar(16),                       -- add this field for using cwms DB
    version_date date,                         -- add this field for using cwms DB
	PRIMARY KEY (RECORD_NUM)
) &TBL_SPACE_SPEC;

create unique index cp_comp_tasklist_idx_app
    on cp_comp_tasklist(loading_application_id, record_num) &TBL_SPACE_SPEC;

CREATE TABLE CP_COMP_TS_PARM
(
	COMPUTATION_ID NUMBER(18) NOT NULL,
	ALGO_ROLE_NAME VARCHAR2(24) NOT NULL,
	-- Only for non-group comps where the TS is completely specified.
	SITE_DATATYPE_ID NUMBER(18),
	-- Must be either null or match a valid interval code
	INTERVAL_ABBR VARCHAR2(24),
	-- Stores overrides for duration, param type, and version
	TABLE_SELECTOR VARCHAR2(240),
	DELTA_T INT DEFAULT 0 NOT NULL,
	-- Placeholder
	MODEL_ID INT,
	-- For group comps, this overrides datatype of triggering param
	DATATYPE_ID NUMBER(18),
	-- If null, default is seconds
	DELTA_T_UNITS VARCHAR2(24),
	-- For group comps, this overrides the site selection.
	SITE_ID NUMBER(18),
	CONSTRAINT comp_parm_unique UNIQUE (COMPUTATION_ID, ALGO_ROLE_NAME)
) &TBL_SPACE_SPEC;


CREATE TABLE CP_DEPENDS_NOTIFY
(
	RECORD_NUM INT NOT NULL,
	EVENT_TYPE CHAR NOT NULL,
	KEY INT NOT NULL,
	DATE_TIME_LOADED date NOT NULL,
	PRIMARY KEY (RECORD_NUM)
) &TBL_SPACE_SPEC;


CREATE TABLE DACQ_EVENT
(
	-- Surrogate Key. Events are numbered from 0...MAX
	DACQ_EVENT_ID NUMBER(18) NOT NULL,
	SCHEDULE_ENTRY_STATUS_ID NUMBER(18),
	PLATFORM_ID NUMBER(18),
	EVENT_TIME date NOT NULL,
	-- INFO = 3, WARNING = 4, FAILURE = 5, FATAL = 6
	-- 
	EVENT_PRIORITY INT NOT NULL,
	-- Software subsystem that generated this event
	SUBSYSTEM VARCHAR2(24) NOT NULL,
    -- If this is related to a message, this holds the message's local_recv_time.
    MSG_RECV_TIME DATE,
	EVENT_TEXT VARCHAR2(256) NOT NULL,
	db_office_code integer default &dflt_office_code,
	PRIMARY KEY (DACQ_EVENT_ID)
) &TBL_SPACE_SPEC;


CREATE TABLE DATAPRESENTATION
(
	ID NUMBER(18) NOT NULL,
	GROUPID NUMBER(18) NOT NULL,
	DATATYPEID NUMBER(18) NOT NULL,
	-- Must match a units abbreviation
	UNITABBR VARCHAR2(24),
	EQUIPMENTID NUMBER(18),
	MAXDECIMALS INT,
	-- Upper limit. Values higher than this are discarded.
	-- Null means no limit.
	MAX_VALUE DOUBLE PRECISION,
	-- Minimum value. Values below this are discarded.
	-- Null means no limit.
	MIN_VALUE DOUBLE PRECISION,
	PRIMARY KEY (ID),
	CONSTRAINT pres_dt_unique UNIQUE (GROUPID, DATATYPEID)
) &TBL_SPACE_SPEC;


CREATE TABLE DATASOURCE
(
	ID NUMBER(18) NOT NULL,
	NAME VARCHAR2(64) NOT NULL,
	-- Must match enum DataSourceType value.
	DATASOURCETYPE VARCHAR2(24) NOT NULL,
	-- interpretation depends on the data source type
	DATASOURCEARG VARCHAR2(400),
	db_office_code integer default &dflt_office_code,
	PRIMARY KEY (ID),
	CONSTRAINT DSNAME_UNIQUE UNIQUE(NAME, db_office_code)
) &TBL_SPACE_SPEC;


CREATE TABLE DATASOURCEGROUPMEMBER
(
	GROUPID NUMBER(18) NOT NULL,
	-- Determines order of data sources within the group
	SEQUENCENUM INT NOT NULL,
	MEMBERID NUMBER(18) NOT NULL,
	PRIMARY KEY (GROUPID, MEMBERID),
	CONSTRAINT group_seq_unique UNIQUE (GROUPID, SEQUENCENUM)
) &TBL_SPACE_SPEC;


CREATE TABLE DATATYPE
(
	ID NUMBER(18) NOT NULL,
	STANDARD VARCHAR2(24) NOT NULL,
	CODE VARCHAR2(65) NOT NULL,
	-- Used for reports and GUIs.
	DISPLAY_NAME VARCHAR2(64),
	db_office_code integer default &dflt_office_code,
	PRIMARY KEY (ID),
	CONSTRAINT dt_std_code_unique UNIQUE (STANDARD, CODE, db_office_code)
) &TBL_SPACE_SPEC;


-- An entry in this table expresses that two different data types are to be considered equivalent.
CREATE TABLE DATATYPEEQUIVALENCE
(
	ID0 INT NOT NULL,
	ID1 INT NOT NULL,
	PRIMARY KEY (ID0, ID1)
) &TBL_SPACE_SPEC;


CREATE TABLE DECODESDATABASEVERSION
(
	-- Should be only one record representing the highest numbered version.
	-- For backward compat, sw will only look at max version number.
	VERSION_NUM INT NOT NULL,
	-- Options expressed as comma-separated name=value pairs.
	DB_OPTIONS VARCHAR2(400),
	PRIMARY KEY (VERSION_NUM)
) &TBL_SPACE_SPEC;


CREATE TABLE DECODESSCRIPT
(
	ID NUMBER(18) NOT NULL,
	CONFIGID NUMBER(18) NOT NULL,
	NAME VARCHAR2(64) NOT NULL,
	-- Enumeration value for script type
	SCRIPT_TYPE VARCHAR2(24) DEFAULT 'DECODES' NOT NULL,
	-- 'A'=Ascending, 'D'=Descending
	DATAORDER CHAR DEFAULT 'A' NOT NULL,
	PRIMARY KEY (ID),
	CONSTRAINT config_script_name_unique UNIQUE (CONFIGID, NAME)
) &TBL_SPACE_SPEC;


CREATE TABLE ENGINEERINGUNIT
(
	-- Standard abbreviation for this unit identifier
	UNITABBR VARCHAR2(24) NOT NULL,
	-- Full name
	NAME VARCHAR2(64),
	-- Either 'English', 'Metric', or 'Standard'
	FAMILY VARCHAR2(24) NOT NULL,
	-- States what physical quantity this unit measures.
	-- E.g. 'ft' measures 'length'
	MEASURES VARCHAR2(24) NOT NULL,
	db_office_code integer default &dflt_office_code,
	PRIMARY KEY (UNITABBR, db_office_code)
) &TBL_SPACE_SPEC;


-- An enumeration
CREATE TABLE ENUM
(
	ID NUMBER(18) NOT NULL,
	-- The name of this enumeration
	NAME VARCHAR2(24) NOT NULL,
	-- Null means no default. Else should match one of the values.
	DEFAULTVALUE VARCHAR2(24),
	-- Description of what this enumeration is used for
	DESCRIPTION VARCHAR2(400),
	db_office_code integer default &dflt_office_code,
	PRIMARY KEY (ID),
	CONSTRAINT ENNAME_UNIQUE UNIQUE(NAME, db_office_code)
) &TBL_SPACE_SPEC;


CREATE TABLE ENUMVALUE
(
	ENUMID NUMBER(18) NOT NULL,
	-- The short, unique enum value. Typically an abreviation.
	ENUMVALUE VARCHAR2(24) NOT NULL,
	-- Description of this enum value
	DESCRIPTION VARCHAR2(400),
	-- Java class for execution when this enum value is selected
	EXECCLASS VARCHAR2(160),
	-- Java class for editing when this enum value is selected.
	EDITCLASS VARCHAR2(160),
	-- Order of this value within the enumeration.
	SORTNUMBER INT,
	PRIMARY KEY (ENUMID, ENUMVALUE)
) &TBL_SPACE_SPEC;


CREATE TABLE EQUIPMENTMODEL
(
	ID NUMBER(18) NOT NULL,
	NAME VARCHAR2(24) NOT NULL,
	COMPANY VARCHAR2(64),
	MODEL VARCHAR2(64),
	DESCRIPTION VARCHAR2(400),
	EQUIPMENTTYPE VARCHAR2(24),
	db_office_code integer default &dflt_office_code,
	PRIMARY KEY (ID),
	CONSTRAINT EQNAME_UNIQUE UNIQUE(NAME, db_office_code)
) &TBL_SPACE_SPEC;


CREATE TABLE EQUIPMENTPROPERTY
(
	EQUIPMENTID NUMBER(18) NOT NULL,
	NAME VARCHAR2(24) NOT NULL,
	PROP_VALUE VARCHAR2(240) NOT NULL,
	CONSTRAINT equip_prop_name_unique UNIQUE (EQUIPMENTID, NAME)
) &TBL_SPACE_SPEC;


CREATE TABLE FORMATSTATEMENT
(
	DECODESSCRIPTID NUMBER(18) NOT NULL,
	-- Determines execution order
	SEQUENCENUM INT NOT NULL,
	-- Statement Label
	LABEL VARCHAR2(24) NOT NULL,
	FORMAT VARCHAR2(400),
	CONSTRAINT script_sequence_unique UNIQUE (DECODESSCRIPTID, SEQUENCENUM)
) &TBL_SPACE_SPEC;


CREATE TABLE HDB_LOADING_APPLICATION
(
	LOADING_APPLICATION_ID NUMBER(18) NOT NULL,
	-- Unique name of this loading app
	LOADING_APPLICATION_NAME VARCHAR2(24) NOT NULL,
	-- True if this app does manual editing
	MANUAL_EDIT_APP CHAR(1) DEFAULT 'N' NOT NULL,
	CMMNT VARCHAR2(1000),
	db_office_code integer default &dflt_office_code,
	PRIMARY KEY (LOADING_APPLICATION_ID),
	CONSTRAINT APPNAME_UNIQUE UNIQUE(LOADING_APPLICATION_NAME, db_office_code)
) &TBL_SPACE_SPEC;


CREATE TABLE INTERVAL_CODE
(
	INTERVAL_ID NUMBER(18) NOT NULL,
	-- Interval Name for Display in Pull-Down lists, files, etc.
	NAME VARCHAR2(24) NOT NULL,
	-- Java Calendar Constant Name.
	-- One of MINUTE, HOUR_OF_DAY, DAY_OF_MONTH, WEEK_OF_YEAR, MONTH, YEAR
	CAL_CONSTANT VARCHAR2(16) NOT NULL,
	-- Multiplier for calendar constant.
	-- Zero means instantaneous.
	CAL_MULTIPLIER INT NOT NULL,
	PRIMARY KEY (INTERVAL_ID),
	CONSTRAINT ICNAME_UNIQUE UNIQUE(NAME)
) &TBL_SPACE_SPEC;


-- A network list is a list of platforms, denoted by a transport medium.
CREATE TABLE NETWORKLIST
(
	ID NUMBER(18) NOT NULL,
	NAME VARCHAR2(64) NOT NULL,
	-- Must match transport medium type enum value
	TRANSPORTMEDIUMTYPE VARCHAR2(24) NOT NULL,
	-- If not null, must match a site name type enum value.
	SITENAMETYPEPREFERENCE VARCHAR2(24) NOT NULL,
	LASTMODIFYTIME date NOT NULL,
	db_office_code integer default &dflt_office_code,
	PRIMARY KEY (ID),
	CONSTRAINT NLNAME_UNIQUE UNIQUE(NAME, db_office_code)
) &TBL_SPACE_SPEC;


CREATE TABLE NETWORKLISTENTRY
(
	NETWORKLISTID NUMBER(18) NOT NULL,
	-- Must match a transport medium id
	TRANSPORTID VARCHAR2(64) NOT NULL,
	-- Short mnemonic platform name
	PLATFORM_NAME VARCHAR2(24),
	DESCRIPTION VARCHAR2(80),
	PRIMARY KEY (NETWORKLISTID, TRANSPORTID)
) &TBL_SPACE_SPEC;


CREATE TABLE PLATFORM
(
	ID NUMBER(18) NOT NULL,
	-- Agency that owns or controls this platform
	AGENCY VARCHAR2(64),
	ISPRODUCTION VARCHAR2(5) DEFAULT 'false' NOT NULL,
	SITEID NUMBER(18),
	CONFIGID NUMBER(18),
	DESCRIPTION VARCHAR2(400),
	LASTMODIFYTIME date NOT NULL,
	-- If null this platform is not expired (i.e. it is current).
	EXPIRATION date,
	-- To distinguish multiple platforms at the same site.
	PLATFORMDESIGNATOR VARCHAR2(24),
	PRIMARY KEY (ID),
	CONSTRAINT site_designator_unique UNIQUE (SITEID, PLATFORMDESIGNATOR)
) &TBL_SPACE_SPEC;


CREATE TABLE PLATFORMCONFIG
(
	ID NUMBER(18) NOT NULL,
	-- Unique configuration name
	NAME VARCHAR2(64) NOT NULL,
	DESCRIPTION VARCHAR2(400),
	-- Legacy
	EQUIPMENTID NUMBER(18),
	db_office_code integer default &dflt_office_code,
	PRIMARY KEY (ID),
	CONSTRAINT PCNAME_UNIQUE UNIQUE(NAME, db_office_code)
) &TBL_SPACE_SPEC;


CREATE TABLE PLATFORMPROPERTY
(
	PLATFORMID NUMBER(18) NOT NULL,
	PROP_NAME VARCHAR2(24) NOT NULL,
	PROP_VALUE VARCHAR2(240) NOT NULL,
	PRIMARY KEY (PLATFORMID, PROP_NAME)
) &TBL_SPACE_SPEC;


CREATE TABLE PLATFORMSENSOR
(
	PLATFORMID NUMBER(18) NOT NULL,
	SENSORNUMBER INT NOT NULL,
	SITEID NUMBER(18),
	-- Database Descriptor Number - Legacy field for USGS compatibility
	DD_NU INT,
	PRIMARY KEY (PLATFORMID, SENSORNUMBER)
) &TBL_SPACE_SPEC;


CREATE TABLE PLATFORMSENSORPROPERTY
(
	PLATFORMID NUMBER(18) NOT NULL,
	SENSORNUMBER INT NOT NULL,
	PROP_NAME VARCHAR2(24),
	PROP_VALUE VARCHAR2(240),
	PRIMARY KEY (PLATFORMID, SENSORNUMBER, PROP_NAME)
) &TBL_SPACE_SPEC;


CREATE TABLE PLATFORM_STATUS
(
	PLATFORM_ID NUMBER(18) NOT NULL,
	-- Time of last station contact, whether or not a message was successfully received.
	LAST_CONTACT_TIME date,
	-- Time stamp of last message received. This is the message time stamp parsed from the header.
	-- Null means no message ever received.
	LAST_MESSAGE_TIME date,
	-- Up to 8 failure codes describing data acquisition and decoding.
	LAST_FAILURE_CODES VARCHAR2(8),
	-- Null means no errors encountered ever.
	LAST_ERROR_TIME date,
	-- Points to status of last routing spec / schedule entry run.
	-- Null means that the schedule entry is too old and has been purged.
	LAST_SCHEDULE_ENTRY_STATUS_ID NUMBER(18),
	ANNOTATION VARCHAR2(400),
	PRIMARY KEY (PLATFORM_ID)
) &TBL_SPACE_SPEC;


CREATE TABLE PRESENTATIONGROUP
(
	ID NUMBER(18) NOT NULL,
	NAME VARCHAR2(64) NOT NULL,
	-- If not null, this refers to the parent group from which this group inherits.
	INHERITSFROM NUMBER(18),
	LASTMODIFYTIME date NOT NULL,
	ISPRODUCTION VARCHAR2(5) DEFAULT 'FALSE' NOT NULL,
	db_office_code integer default &dflt_office_code,
	PRIMARY KEY (ID),
	CONSTRAINT PGNAME_UNIQUE UNIQUE(NAME, db_office_code)
) &TBL_SPACE_SPEC;


CREATE TABLE REF_LOADING_APPLICATION_PROP
(
	LOADING_APPLICATION_ID NUMBER(18) NOT NULL,
	PROP_NAME VARCHAR2(64) NOT NULL,
	PROP_VALUE VARCHAR2(240) NOT NULL,
	PRIMARY KEY (LOADING_APPLICATION_ID, PROP_NAME)
) &TBL_SPACE_SPEC;


CREATE TABLE ROUNDINGRULE
(
	DATAPRESENTATIONID NUMBER(18) NOT NULL,
	UPPERLIMIT DOUBLE PRECISION NOT NULL,
	SIGDIGITS INT NOT NULL,
	PRIMARY KEY (DATAPRESENTATIONID, UPPERLIMIT)
) &TBL_SPACE_SPEC;


CREATE TABLE ROUTINGSPEC
(
	ID NUMBER(18) NOT NULL,
	NAME VARCHAR2(64) NOT NULL,
	DATASOURCEID NUMBER(18) NOT NULL,
	-- True to enable in-line equations in this routing spec.
	ENABLEEQUATIONS VARCHAR2(5) DEFAULT 'FALSE' NOT NULL,
	-- True to output performance measurements as if they were sensor values.
	USEPERFORMANCEMEASUREMENTS VARCHAR2(5) DEFAULT 'FALSE' NOT NULL,
	-- Must match an enum value for output formatter
	OUTPUTFORMAT VARCHAR2(24),
	-- Java timezone to format output. If null, default to UTC.
	OUTPUTTIMEZONE VARCHAR2(64),
	PRESENTATIONGROUPNAME VARCHAR2(64),
	SINCETIME VARCHAR2(80),
	UNTILTIME VARCHAR2(80),
	-- Must match a consumer type enum value.
	CONSUMERTYPE VARCHAR2(24) NOT NULL,
	-- type-dependent argument for the consumer
	CONSUMERARG VARCHAR2(400),
	LASTMODIFYTIME date NOT NULL,
	ISPRODUCTION VARCHAR2(5) DEFAULT 'FALSE' NOT NULL,
	db_office_code integer default &dflt_office_code,
	PRIMARY KEY (ID),
	CONSTRAINT RSNAME_UNIQUE UNIQUE(NAME, db_office_code)
) &TBL_SPACE_SPEC;


CREATE TABLE ROUTINGSPECNETWORKLIST
(
	ROUTINGSPECID NUMBER(18) NOT NULL,
	NETWORKLISTNAME VARCHAR2(64) NOT NULL,
	PRIMARY KEY (ROUTINGSPECID, NETWORKLISTNAME)
) &TBL_SPACE_SPEC;


CREATE TABLE ROUTINGSPECPROPERTY
(
	ROUTINGSPECID NUMBER(18) NOT NULL,
	PROP_NAME VARCHAR2(24) NOT NULL,
	PROP_VALUE VARCHAR2(240) NOT NULL,
	PRIMARY KEY (ROUTINGSPECID, PROP_NAME)
) &TBL_SPACE_SPEC;


CREATE TABLE SCHEDULE_ENTRY
(
	SCHEDULE_ENTRY_ID NUMBER(18) NOT NULL,
	-- Unique name for this schedule entry.
	NAME VARCHAR2(64) NOT NULL,
	LOADING_APPLICATION_ID NUMBER(18),
	ROUTINGSPEC_ID NUMBER(18) NOT NULL,
	-- date/time for first execution.
	-- Null means start immediately.
	START_TIME date,
	-- Used to interpret interval adding to start time.
	TIMEZONE VARCHAR2(32),
	-- Any valid interval in this database.
	-- Null means execute one time only.
	RUN_INTERVAL VARCHAR2(64),
	-- true or false
	ENABLED VARCHAR2(5) NOT NULL,
	LAST_MODIFIED date NOT NULL,
	db_office_code integer default &dflt_office_code,
	PRIMARY KEY (SCHEDULE_ENTRY_ID),
	CONSTRAINT SENAME_UNIQUE UNIQUE(NAME, db_office_code)
) &TBL_SPACE_SPEC;


-- Describes a schedule run.
CREATE TABLE SCHEDULE_ENTRY_STATUS
(
	SCHEDULE_ENTRY_STATUS_ID NUMBER(18) NOT NULL,
	SCHEDULE_ENTRY_ID NUMBER(18) NOT NULL,
	RUN_START_TIME date NOT NULL,
	-- Null means no messages yet received
	LAST_MESSAGE_TIME date,
	-- Null means still running.
	RUN_COMPLETE_TIME date,
	-- Hostname or IP Address of server where the routing spec was run.
	HOSTNAME VARCHAR2(64) NOT NULL,
	-- Brief string describing current status: "initializing", "running", "complete", "failed".
	RUN_STATUS VARCHAR2(24) NOT NULL,
	-- Number of messages successfully processed during the run.
	NUM_MESSAGES INT DEFAULT 0 NOT NULL,
	-- Number of decoding errors encountered.
	NUM_DECODE_ERRORS INT DEFAULT 0 NOT NULL,
	-- Number of distinct platforms seen
	NUM_PLATFORMS INT DEFAULT 0 NOT NULL,
	LAST_SOURCE VARCHAR2(32),
	LAST_CONSUMER VARCHAR2(32),
	-- Last time this entry was written to the database.
	LAST_MODIFIED date NOT NULL,
	PRIMARY KEY (SCHEDULE_ENTRY_STATUS_ID),
	CONSTRAINT sched_entry_start_unique UNIQUE (SCHEDULE_ENTRY_ID, RUN_START_TIME)
) &TBL_SPACE_SPEC;


CREATE TABLE SCRIPTSENSOR
(
	DECODESSCRIPTID NUMBER(18) NOT NULL,
	SENSORNUMBER INT NOT NULL,
	UNITCONVERTERID NUMBER(18) NOT NULL,
	PRIMARY KEY (DECODESSCRIPTID, SENSORNUMBER)
) &TBL_SPACE_SPEC;


CREATE TABLE SERIAL_PORT_STATUS
(
	-- Combo of DigiHostName:PortNumber
	PORT_NAME VARCHAR2(48) NOT NULL,
	-- True when port is locked.
	IN_USE VARCHAR2(5) DEFAULT 'FALSE' NOT NULL,
	-- Name of routing spec (or other process) that last used (or is currently using) the port.
	-- Null means never been used.
	LAST_USED_BY_PROC VARCHAR2(64),
	-- Hostname or IP Address from which this port was last used (or is currently being used).
	-- Null means never been used.
	LAST_USED_BY_HOST VARCHAR2(64),
	-- Java msec Date/Time this port was last used.
	LAST_ACTIVITY_TIME DATE,
	-- Java msec Date/Time that a message was successfully received on this port.
	LAST_RECEIVE_TIME DATE,
	-- The Medium ID (e.g. logger name) from which a message was last received on this port.
	LAST_MEDIUM_ID VARCHAR2(64),
	-- Java msec Date/Time of the last time an error occurred on this port.
	LAST_ERROR_TIME DATE,
	-- Short string. Usually one of the following:
	-- idle, dialing, login, receiving, goodbye, error
	PORT_STATUS VARCHAR2(32),
	PRIMARY KEY (PORT_NAME)
) &TBL_SPACE_SPEC;

-- NOTE: CWMS Locations are mapped to DECODES Sites. So no SITE table in CWMS.
-- CREATE TABLE SITE
-- (
-- 	ID INT NOT NULL,
-- 	LATITUDE VARCHAR2(24),
-- 	LONGITUDE VARCHAR2(24),
-- 	NEARESTCITY VARCHAR2(64),
-- 	STATE VARCHAR2(24),
-- 	REGION VARCHAR2(64),
-- 	TIMEZONE VARCHAR2(64),
-- 	COUNTRY VARCHAR2(64),
-- 	ELEVATION DOUBLE PRECISION,
-- 	ELEVUNITABBR VARCHAR2(24) DEFAULT 'ft' NOT NULL,
-- 	DESCRIPTION VARCHAR2(800),
-- 	ACTIVE_FLAG VARCHAR2(5) DEFAULT 'TRUE' NOT NULL,
-- 	LOCATION_TYPE VARCHAR2(32),
-- 	MODIFY_TIME NUMBER(19) NOT NULL,
-- 	PUBLIC_NAME VARCHAR2(64),
-- 	PRIMARY KEY (ID)
-- ) &TBL_SPACE_SPEC;
 

CREATE TABLE SITENAME
(
	SITEID NUMBER(18) NOT NULL,
	-- Must match one of the Enumerated Site Name Types
	NAMETYPE VARCHAR2(24) NOT NULL,
	-- Combination (location.office_code, nameType, siteName) must be unique
	SITENAME VARCHAR2(64) NOT NULL,
	-- For USGS compatibility
	DBNUM VARCHAR2(2),
	-- For USGS Compatibility
	AGENCY_CD VARCHAR2(5),
	PRIMARY KEY (SITEID, NAMETYPE)
) &TBL_SPACE_SPEC;


CREATE TABLE SITE_PROPERTY
(
	SITE_ID NUMBER(18) NOT NULL,
	PROP_NAME VARCHAR2(24) NOT NULL,
	PROP_VALUE VARCHAR2(240) NOT NULL,
	PRIMARY KEY (SITE_ID, PROP_NAME)
) &TBL_SPACE_SPEC;


CREATE TABLE TRANSPORTMEDIUM
(
	PLATFORMID NUMBER(18) NOT NULL,
	MEDIUMTYPE VARCHAR2(24) NOT NULL,
	MEDIUMID VARCHAR2(64) NOT NULL,
	-- Script to use to decode data from this TM
	SCRIPTNAME VARCHAR2(64),
	-- Channel number for GOES transport media
	CHANNELNUM INT,
	-- Second of day of first transmission, UTC.
	ASSIGNEDTIME INT,
	-- Length in seconds of transmit window
	TRANSMITWINDOW INT,
	-- Interval in seconds between transmissions
	TRANSMITINTERVAL INT,
	-- Legacy - not used
	EQUIPMENTID NUMBER(18),
	-- # of seconds to add to each transmit time from this TM
	TIMEADJUSTMENT INT,
	-- L=long, S=Short for GOES
	PREAMBLE CHAR,
	-- Java time zone name used to parse date/time values that are in the message.
	-- This doesn't count time parsed from a message header which are usually in a known TZ.
	TIMEZONE VARCHAR2(64),
	LOGGERTYPE VARCHAR2(24),
	BAUD INT,
	STOPBITS INT,
	PARITY VARCHAR2(1),
	DATABITS INT,
	-- TRUE or FALSE
	DOLOGIN VARCHAR2(5),
	USERNAME VARCHAR2(32),
	PASSWORD VARCHAR2(32),

	db_office_code integer default &dflt_office_code,
	PRIMARY KEY (PLATFORMID, MEDIUMTYPE)
) &TBL_SPACE_SPEC;

-- Guarantees no two transportmedia have same type and id.
create unique index transportmediumidx
    on transportmedium(mediumtype,mediumid,db_office_code) &TBL_SPACE_SPEC;

-- There should be a single row in this table. When schema is updated, the old row should be removed.
CREATE TABLE TSDB_DATABASE_VERSION
(
	DB_VERSION INT NOT NULL,
	DESCRIPTION VARCHAR2(400) NOT NULL,
	PRIMARY KEY (DB_VERSION)
) &TBL_SPACE_SPEC;


CREATE TABLE TSDB_GROUP
(
	GROUP_ID NUMBER(18) NOT NULL,
	GROUP_NAME VARCHAR2(64) NOT NULL,
	-- Must match a group_type enumeration value.
	GROUP_TYPE VARCHAR2(24) NOT NULL,
	GROUP_DESCRIPTION VARCHAR2(1000),
	db_office_code integer default &dflt_office_code,
	PRIMARY KEY (GROUP_ID),
	CONSTRAINT GROUP_NAME_UNIQUE UNIQUE(GROUP_NAME, db_office_code)
) &TBL_SPACE_SPEC;


CREATE TABLE TSDB_GROUP_MEMBER_DT
(
	GROUP_ID NUMBER(18) NOT NULL,
	DATA_TYPE_ID NUMBER(18) NOT NULL,
	PRIMARY KEY (GROUP_ID, DATA_TYPE_ID)
) &TBL_SPACE_SPEC;


CREATE TABLE TSDB_GROUP_MEMBER_GROUP
(
	PARENT_GROUP_ID NUMBER(18) NOT NULL,
	CHILD_GROUP_ID NUMBER(18) NOT NULL,
	-- How to combine child with parent: A=Add, S=Subtract, I=Intersect
	INCLUDE_GROUP CHAR DEFAULT 'A' NOT NULL,
	PRIMARY KEY (PARENT_GROUP_ID, CHILD_GROUP_ID)
) &TBL_SPACE_SPEC;


CREATE TABLE TSDB_GROUP_MEMBER_OTHER
(
	GROUP_ID NUMBER(18) NOT NULL,
	-- Must match one of the database's underlying TS ID Parts.
	MEMBER_TYPE VARCHAR2(24) NOT NULL,
	MEMBER_VALUE VARCHAR2(240) NOT NULL
) &TBL_SPACE_SPEC;


CREATE TABLE TSDB_GROUP_MEMBER_SITE
(
	GROUP_ID NUMBER(18) NOT NULL,
	SITE_ID NUMBER(18) NOT NULL,
	PRIMARY KEY (GROUP_ID, SITE_ID)
) &TBL_SPACE_SPEC;


CREATE TABLE TSDB_GROUP_MEMBER_TS
(
	GROUP_ID NUMBER(18) NOT NULL,
	TS_ID NUMBER(18) NOT NULL,
	PRIMARY KEY (GROUP_ID, TS_ID)
) &TBL_SPACE_SPEC;


-- Global properties on the database components.
CREATE TABLE TSDB_PROPERTY
(
	PROP_NAME VARCHAR2(24) NOT NULL,
	PROP_VALUE VARCHAR2(240) NOT NULL,
	PRIMARY KEY (PROP_NAME)
) &TBL_SPACE_SPEC;


CREATE TABLE UNITCONVERTER
(
	ID NUMBER(18) NOT NULL,
	-- Standard abbreviation for this unit identifier
	FROMUNITSABBR VARCHAR2(24) NOT NULL,
	-- Standard abbreviation for this unit identifier
	TOUNITSABBR VARCHAR2(24) NOT NULL,
	ALGORITHM VARCHAR2(24) NOT NULL,
	A DOUBLE PRECISION,
	B DOUBLE PRECISION,
	C DOUBLE PRECISION,
	D DOUBLE PRECISION,
	E DOUBLE PRECISION,
	F DOUBLE PRECISION,
	db_office_code integer default &dflt_office_code,
	PRIMARY KEY (ID)
) &TBL_SPACE_SPEC;



ALTER TABLE CONFIGSENSORDATATYPE
	ADD CONSTRAINT CONFIGSENSORDATATYPE_FKCS
	FOREIGN KEY (CONFIGID, SENSORNUMBER)
	REFERENCES CONFIGSENSOR (CONFIGID, SENSORNUMBER)
;


ALTER TABLE CONFIGSENSORPROPERTY
	ADD CONSTRAINT CONFIGSENSORPROPERTY_FK
	FOREIGN KEY (CONFIGID, SENSORNUMBER)
	REFERENCES CONFIGSENSOR (CONFIGID, SENSORNUMBER)
;


ALTER TABLE CP_ALGO_PROPERTY
	ADD CONSTRAINT CP_ALGO_PROPERTY_FK
	FOREIGN KEY (ALGORITHM_ID)
	REFERENCES CP_ALGORITHM (ALGORITHM_ID)
;


ALTER TABLE CP_ALGO_TS_PARM
	ADD CONSTRAINT CP_ALGO_TS_PARM_FK
	FOREIGN KEY (ALGORITHM_ID)
	REFERENCES CP_ALGORITHM (ALGORITHM_ID)
;


ALTER TABLE CP_COMPUTATION
	ADD CONSTRAINT CP_COMPUTATION_FK
	FOREIGN KEY (ALGORITHM_ID)
	REFERENCES CP_ALGORITHM (ALGORITHM_ID)
;

ALTER TABLE CP_COMPOSITE_DIAGRAM
	ADD CONSTRAINT CP_COMPOSITE_DIAGRAM_FK
	FOREIGN KEY (COMPOSITE_COMPUTATION_ID)
	REFERENCES CP_COMPUTATION (COMPUTATION_ID)
;


ALTER TABLE CP_COMPOSITE_MEMBER
	ADD CONSTRAINT CP_COMPOSITE_MEMBER_FK1
	FOREIGN KEY (COMPOSITE_COMPUTATION_ID)
	REFERENCES CP_COMPUTATION (COMPUTATION_ID)
;


ALTER TABLE CP_COMPOSITE_MEMBER
	ADD CONSTRAINT CP_COMPOSITE_MEMBER_FK2
	FOREIGN KEY (COMPONENT_COMPUTATION_ID)
	REFERENCES CP_COMPUTATION (COMPUTATION_ID)
;

ALTER TABLE CP_COMP_DEPENDS
	ADD CONSTRAINT CP_COMP_DEPENDS_FK
	FOREIGN KEY (COMPUTATION_ID)
	REFERENCES CP_COMPUTATION (COMPUTATION_ID)
;


ALTER TABLE CP_COMP_DEPENDS_SCRATCHPAD
	ADD CONSTRAINT CP_COMP_DEPENDS_SCRATCHPAD_FK
	FOREIGN KEY (COMPUTATION_ID)
	REFERENCES CP_COMPUTATION (COMPUTATION_ID)
;


ALTER TABLE CP_COMP_PROPERTY
	ADD CONSTRAINT CP_COMP_PROPERTY_FK
	FOREIGN KEY (COMPUTATION_ID)
	REFERENCES CP_COMPUTATION (COMPUTATION_ID)
;


ALTER TABLE CP_COMP_TS_PARM
	ADD CONSTRAINT CP_COMP_TS_PARM_FKCO
	FOREIGN KEY (COMPUTATION_ID)
	REFERENCES CP_COMPUTATION (COMPUTATION_ID)
;


ALTER TABLE ROUNDINGRULE
	ADD CONSTRAINT ROUNDINGRULE_FK
	FOREIGN KEY (DATAPRESENTATIONID)
	REFERENCES DATAPRESENTATION (ID)
;


ALTER TABLE DATASOURCEGROUPMEMBER
	ADD CONSTRAINT DATASOURCEGROUPMEMBER_FKME
	FOREIGN KEY (MEMBERID)
	REFERENCES DATASOURCE (ID)
;


ALTER TABLE DATASOURCEGROUPMEMBER
	ADD CONSTRAINT DATASOURCEGROUPMEMBER_FKGR
	FOREIGN KEY (GROUPID)
	REFERENCES DATASOURCE (ID)
;


ALTER TABLE ROUTINGSPEC
	ADD CONSTRAINT ROUTINGSPEC_FK
	FOREIGN KEY (DATASOURCEID)
	REFERENCES DATASOURCE (ID)
;


ALTER TABLE CONFIGSENSORDATATYPE
	ADD CONSTRAINT CONFIGSENSORDATATYPE_FKDT
	FOREIGN KEY (DATATYPEID)
	REFERENCES DATATYPE (ID)
;


ALTER TABLE CP_COMP_TS_PARM
	ADD CONSTRAINT CP_COMP_TS_PARM_FKDT
	FOREIGN KEY (DATATYPE_ID)
	REFERENCES DATATYPE (ID)
;


ALTER TABLE DATAPRESENTATION
	ADD CONSTRAINT DATAPRESENTATION_FK
	FOREIGN KEY (DATATYPEID)
	REFERENCES DATATYPE (ID)
;


ALTER TABLE DATATYPEEQUIVALENCE
	ADD CONSTRAINT DATATYPEEQUIVALENCE_FK
	FOREIGN KEY (ID0)
	REFERENCES DATATYPE (ID)
;


ALTER TABLE DATATYPEEQUIVALENCE
	ADD CONSTRAINT DATATYPEEQUIVALENCE
	FOREIGN KEY (ID1)
	REFERENCES DATATYPE (ID)
;


ALTER TABLE TSDB_GROUP_MEMBER_DT
	ADD CONSTRAINT TSDB_GROUP_MEMBER_DT_FK
	FOREIGN KEY (DATA_TYPE_ID)
	REFERENCES DATATYPE (ID)
;

ALTER TABLE FORMATSTATEMENT
	ADD CONSTRAINT FORMATSTATEMENT_FKDS
	FOREIGN KEY (DECODESSCRIPTID)
	REFERENCES DECODESSCRIPT (ID)
;


ALTER TABLE SCRIPTSENSOR
	ADD CONSTRAINT SCRIPTSENSOR_FKDS
	FOREIGN KEY (DECODESSCRIPTID)
	REFERENCES DECODESSCRIPT (ID)
;


ALTER TABLE ENUMVALUE
	ADD CONSTRAINT ENUMVALUE_FK
	FOREIGN KEY (ENUMID)
	REFERENCES ENUM (ID)
;


ALTER TABLE DATAPRESENTATION
	ADD CONSTRAINT DATAPRESENTATION_FKEM
	FOREIGN KEY (EQUIPMENTID)
	REFERENCES EQUIPMENTMODEL (ID)
;


ALTER TABLE EQUIPMENTPROPERTY
	ADD CONSTRAINT EQUIPMENTPROPERTY_FKEQ
	FOREIGN KEY (EQUIPMENTID)
	REFERENCES EQUIPMENTMODEL (ID)
;


ALTER TABLE CP_COMPUTATION
	ADD CONSTRAINT CP_COMPUTATION_FKLA
	FOREIGN KEY (LOADING_APPLICATION_ID)
	REFERENCES HDB_LOADING_APPLICATION (LOADING_APPLICATION_ID)
;


ALTER TABLE CP_COMP_PROC_LOCK
	ADD CONSTRAINT CP_COMP_PROC_LOCK_FKLA
	FOREIGN KEY (LOADING_APPLICATION_ID)
	REFERENCES HDB_LOADING_APPLICATION (LOADING_APPLICATION_ID)
;


ALTER TABLE CP_COMP_TASKLIST
	ADD CONSTRAINT CP_COMP_TASKLIST_FKLA
	FOREIGN KEY (LOADING_APPLICATION_ID)
	REFERENCES HDB_LOADING_APPLICATION (LOADING_APPLICATION_ID)
;


ALTER TABLE REF_LOADING_APPLICATION_PROP
	ADD CONSTRAINT APP_PROP_FKLA
	FOREIGN KEY (LOADING_APPLICATION_ID)
	REFERENCES HDB_LOADING_APPLICATION (LOADING_APPLICATION_ID)
;


ALTER TABLE SCHEDULE_ENTRY
	ADD CONSTRAINT SCHEDULE_ENTRY_FKLA
	FOREIGN KEY (LOADING_APPLICATION_ID)
	REFERENCES HDB_LOADING_APPLICATION (LOADING_APPLICATION_ID)
;


ALTER TABLE NETWORKLISTENTRY
	ADD CONSTRAINT NETWORKLISTENTRY_FKNL
	FOREIGN KEY (NETWORKLISTID)
	REFERENCES NETWORKLIST (ID)
;


ALTER TABLE DACQ_EVENT
	ADD CONSTRAINT DACQ_EVENT_FKPL
	FOREIGN KEY (PLATFORM_ID)
	REFERENCES PLATFORM (ID)
;


ALTER TABLE PLATFORMPROPERTY
	ADD CONSTRAINT PLATFORMPROPERTY_FKPL
	FOREIGN KEY (PLATFORMID)
	REFERENCES PLATFORM (ID)
;


ALTER TABLE PLATFORMSENSOR
	ADD CONSTRAINT PLATFORMSENSOR_FKPL
	FOREIGN KEY (PLATFORMID)
	REFERENCES PLATFORM (ID)
;


ALTER TABLE PLATFORM_STATUS
	ADD CONSTRAINT PLATFORM_STATUS_FKPL
	FOREIGN KEY (PLATFORM_ID)
	REFERENCES PLATFORM (ID)
;


ALTER TABLE TRANSPORTMEDIUM
	ADD CONSTRAINT TRANSPORTMEDIUM_FKPL
	FOREIGN KEY (PLATFORMID)
	REFERENCES PLATFORM (ID)
;


ALTER TABLE CONFIGSENSOR
	ADD CONSTRAINT CONFIGSENSOR_FKCO
	FOREIGN KEY (CONFIGID)
	REFERENCES PLATFORMCONFIG (ID)
;


ALTER TABLE DECODESSCRIPT
	ADD CONSTRAINT DECODESSCRIPT_FKCO
	FOREIGN KEY (CONFIGID)
	REFERENCES PLATFORMCONFIG (ID)
;


ALTER TABLE PLATFORM
	ADD CONSTRAINT PLATFORM_FKCO
	FOREIGN KEY (CONFIGID)
	REFERENCES PLATFORMCONFIG (ID)
;


ALTER TABLE PLATFORMSENSORPROPERTY
	ADD CONSTRAINT PLATFORMSENSORPROPERTY_FKPS
	FOREIGN KEY (PLATFORMID, SENSORNUMBER)
	REFERENCES PLATFORMSENSOR (PLATFORMID, SENSORNUMBER)
;


ALTER TABLE DATAPRESENTATION
	ADD CONSTRAINT DATAPRESENTATION_FKPG
	FOREIGN KEY (GROUPID)
	REFERENCES PRESENTATIONGROUP (ID)
;


ALTER TABLE PRESENTATIONGROUP
	ADD CONSTRAINT PRESENTATIONGROUP_FKIN
	FOREIGN KEY (INHERITSFROM)
	REFERENCES PRESENTATIONGROUP (ID)
;


ALTER TABLE ROUTINGSPECNETWORKLIST
	ADD CONSTRAINT ROUTINGSPECNETWORKLIST_FKRS
	FOREIGN KEY (ROUTINGSPECID)
	REFERENCES ROUTINGSPEC (ID)
;


ALTER TABLE ROUTINGSPECPROPERTY
	ADD CONSTRAINT ROUTINGSPECPROPERTY_FKRS
	FOREIGN KEY (ROUTINGSPECID)
	REFERENCES ROUTINGSPEC (ID)
;


ALTER TABLE SCHEDULE_ENTRY
	ADD CONSTRAINT SCHEDULE_ENTRY_FKRS
	FOREIGN KEY (ROUTINGSPEC_ID)
	REFERENCES ROUTINGSPEC (ID)
;


ALTER TABLE SCHEDULE_ENTRY_STATUS
	ADD CONSTRAINT SCHEDULE_ENTRY_STATUS_FKSE
	FOREIGN KEY (SCHEDULE_ENTRY_ID)
	REFERENCES SCHEDULE_ENTRY (SCHEDULE_ENTRY_ID)
;


ALTER TABLE DACQ_EVENT
	ADD CONSTRAINT DACQ_EVENT_FKSE
	FOREIGN KEY (SCHEDULE_ENTRY_STATUS_ID)
	REFERENCES SCHEDULE_ENTRY_STATUS (SCHEDULE_ENTRY_STATUS_ID)
;


ALTER TABLE PLATFORM_STATUS
	ADD CONSTRAINT PLATFORM_STATUS_FKSE
	FOREIGN KEY (LAST_SCHEDULE_ENTRY_STATUS_ID)
	REFERENCES SCHEDULE_ENTRY_STATUS (SCHEDULE_ENTRY_STATUS_ID)
;


ALTER TABLE CP_COMPUTATION
	ADD CONSTRAINT CP_COMPUTATION_FKGR
	FOREIGN KEY (GROUP_ID)
	REFERENCES TSDB_GROUP (GROUP_ID)
;


ALTER TABLE TSDB_GROUP_MEMBER_DT
	ADD CONSTRAINT TSDB_GROUP_MEMBER_DT_FKGR
	FOREIGN KEY (GROUP_ID)
	REFERENCES TSDB_GROUP (GROUP_ID)
;


ALTER TABLE TSDB_GROUP_MEMBER_GROUP
	ADD CONSTRAINT TSDB_GROUP_MEMBER_GROUP_FKPA
	FOREIGN KEY (PARENT_GROUP_ID)
	REFERENCES TSDB_GROUP (GROUP_ID)
;


ALTER TABLE TSDB_GROUP_MEMBER_GROUP
	ADD CONSTRAINT TSDB_GROUP_MEMBER_GROUP_FKCH
	FOREIGN KEY (CHILD_GROUP_ID)
	REFERENCES TSDB_GROUP (GROUP_ID)
;


ALTER TABLE TSDB_GROUP_MEMBER_OTHER
	ADD CONSTRAINT TSDB_GROUP_MEMBER_OTHER_FKGR
	FOREIGN KEY (GROUP_ID)
	REFERENCES TSDB_GROUP (GROUP_ID)
;


ALTER TABLE TSDB_GROUP_MEMBER_SITE
	ADD CONSTRAINT TSDB_GROUP_MEMBER_SITE_FKGR
	FOREIGN KEY (GROUP_ID)
	REFERENCES TSDB_GROUP (GROUP_ID)
;


ALTER TABLE TSDB_GROUP_MEMBER_TS
	ADD CONSTRAINT TSDB_GROUP_MEMBER_TS_FKGR
	FOREIGN KEY (GROUP_ID)
	REFERENCES TSDB_GROUP (GROUP_ID)
;


ALTER TABLE SCRIPTSENSOR
	ADD CONSTRAINT SCRIPTSENSOR_FKUC
	FOREIGN KEY (UNITCONVERTERID)
	REFERENCES UNITCONVERTER (ID)
;


CREATE INDEX PLATFORM_ID_IDX ON DACQ_EVENT (PLATFORM_ID) &TBL_SPACE_SPEC;
CREATE INDEX EVT_PLAT_MSG_IDX ON DACQ_EVENT (PLATFORM_ID, MSG_RECV_TIME);
CREATE INDEX EVT_SCHED_IDX ON DACQ_EVENT (SCHEDULE_ENTRY_STATUS_ID);
CREATE INDEX EVT_TIME_IDX ON DACQ_EVENT (EVENT_TIME);


