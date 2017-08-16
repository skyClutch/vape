module.exports = {
  PSQL_URI: 'postgres://pta_dist_14_postgraphql:vapityvapevapevape@localhost:5432/vape',
  // PSQL_URI: 'postgres://pta_dist_14_postgraphql:vapityvapevapevape@pta-dist-14.clluwcqtrt2r.us-west-2.rds.amazonaws.com:5432/vape',
  // PSQL_ADMIN_URI: 'postgres://postgres:W00ki3c00ki3Z@pta-dist-14.clluwcqtrt2r.us-west-2.rds.amazonaws.com:5432/vape',
  PSQL_ADMIN_URI: 'postgres://postgres:W00ki3c00ki3Z@localhost:5432/vape',
  PSQL_DEFAULT_ROLE: 'pta_dist_14_anonymous', // for dev only
  PSQL_SECRET: 'super secret secret stuff',
  PSQL_SCHEMA: 'pta_dist_14',

  GMAIL_USERNAME: '14thdistpresident@gmail.com',
  GMAIL_PASSWORD: '5Children',

  GRAPHIQL: true, // also dev
}
