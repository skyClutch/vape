module.exports = {
  APP_TITLE: '%TITLE%',
  INSECURE_GMAIL_USERNAME: '',
  INSECURE_GMAIL_PASSWORD: '',
  PSQL_URI: 'postgres://%SCHEMA%_postgraphql:DEV_PASSWORD@localhost:5432/vape',
  PSQL_ADMIN_URI: 'postgres://%ADMIN_USERNAME%:%ADMIN_PASSWORD%@localhost:5432/vape',
  PSQL_DEFAULT_ROLE: '%SCHEMA%_anonymous',
  PSQL_SECRET: '%SECRET%',
  PSQL_SCHEMA: '%SCHEMA%',
}
