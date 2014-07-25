GRANT USAGE ON SCHEMA MonMetrics TO mon_persister;
GRANT USAGE ON SCHEMA MonAlarms TO mon_persister;
GRANT ALL ON TABLE MonMetrics.Measurements TO mon_persister;
GRANT ALL ON TABLE MonMetrics.Definitions TO mon_persister;
GRANT ALL ON TABLE MonMetrics.Dimensions TO mon_persister;
GRANT ALL ON TABLE MonMetrics.DefinitionDimensions TO mon_persister;

GRANT USAGE ON SCHEMA MonMetrics TO mon_api;
GRANT USAGE ON SCHEMA MonAlarms TO mon_api;
GRANT SELECT ON TABLE MonMetrics.Measurements TO mon_api;
GRANT SELECT ON TABLE MonMetrics.Definitions TO mon_api;
GRANT SELECT ON TABLE MonMetrics.Dimensions TO mon_api;
GRANT SELECT ON TABLE MonMetrics.DefinitionDimensions TO mon_api;
GRANT ALL ON TABLE MonAlarms.StateHistory TO mon_api;
