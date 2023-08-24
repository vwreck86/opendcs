#
# The 'EditDatabase' is the provisional working database.
# The default installation is set up for a local XML database.
#
EditDatabaseType=OPENTSDB
EditDatabaseLocation=$DECODES_INSTALL_DIR/edit-db

#
# For SQL Editable Database, change EditDatabaseType to sql
# Then...
#   Format for EditDatabaseLocation is a JDBC Database URL:
#
#	    jdbc:protocol:[//host[:port]]/databasename
#
# where
#	protocol is usually the DB product name like 'postgresql'
#	host and port are optional. If not supplied, a local database is assumed.
#	databasename is the database name - required.
#
# example:
#    EditDatabaseLocation=jdbc:postgresql://mylrgs/decodesedit
#

# Settings for the dbedit GUI:
EditPresentationGroup=SHEF-English

# Various agency-specific preferences:
SiteNameTypePreference=NWSHB5
EditTimeZone=UTC
EditOutputFormat=Human-Readable

jdbcDriverClass=org.postgresql.Driver

SqlKeyGenerator=decodes.sql.SequenceKeyGenerator
#sqlDateFormat=
#sqlTimeZone=

transportMediumTypePreference=goes

#defaultDataSource=
#routingStatusDir=
#dataTypeStdPreference=
#decwizTimeZone=
#decwizOutputFormat=
#decwizDebugLevel=
#decwizDecodedDataDir=
#decwizSummaryLog=
