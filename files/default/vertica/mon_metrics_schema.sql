DROP SCHEMA MonMetrics CASCADE; 

CREATE SCHEMA MonMetrics;

CREATE TABLE MonMetrics.Measurements (
    id IDENTITY(1, 1, 1),
    definition_dimensions_id BINARY(20) NOT NULL,
    time_stamp TIMESTAMP NOT NULL,
    value FLOAT NOT NULL,
    PRIMARY KEY(id)
) PARTITION BY EXTRACT('year' FROM time_stamp)*10000 + EXTRACT('month' FROM time_stamp)*100 + EXTRACT('day' FROM time_stamp);

CREATE TABLE MonMetrics.Definitions(
    id BINARY(20) NOT NULL,
    name VARCHAR(255) NOT NULL,
    tenant_id VARCHAR(255) NOT NULL,
    region VARCHAR(255) NOT NULL,
    PRIMARY KEY(id),
    CONSTRAINT MetricsDefinitionsConstraint UNIQUE(name, tenant_id, region)
);

CREATE TABLE MonMetrics.Dimensions (
    dimension_set_id BINARY(20) NOT NULL,
    name VARCHAR(255) NOT NULL,
    value VARCHAR(255) NOT NULL,
    CONSTRAINT MetricsDimensionsConstraint UNIQUE(dimension_set_id, name, value)
);

CREATE TABLE MonMetrics.DefinitionDimensions (
    id BINARY(20) NOT NULL,
    definition_id BINARY(20) NOT NULL,
    dimension_set_id BINARY(20) NOT NULL,
    CONSTRAINT MetricsDefinitionDimensionsConstraint UNIQUE(definition_id, dimension_set_id)
 );

-- Projections
-- ** These are for a single node system with no k safety

CREATE PROJECTION Measurements_DBD_1_rep_MonMetrics /*+createtype(D)*/
(
 id ENCODING AUTO, 
 definition_dimensions_id ENCODING RLE,
 time_stamp ENCODING DELTAVAL, 
 value ENCODING AUTO
)
AS
 SELECT id, 
        definition_dimensions_id, 
        time_stamp, 
        value
 FROM MonMetrics.Measurements 
 ORDER BY definition_dimensions_id,
          time_stamp,
          id
UNSEGMENTED ALL NODES;

CREATE PROJECTION Definitions_DBD_2_rep_MonMetrics /*+createtype(D)*/
(
 id ENCODING RLE, 
 name ENCODING AUTO,
 tenant_id ENCODING RLE, 
 region ENCODING RLE
)
AS
 SELECT id, 
        name, 
        tenant_id, 
        region
 FROM MonMetrics.Definitions 
 ORDER BY id,
          tenant_id,
          region,
          name
UNSEGMENTED ALL NODES;

CREATE PROJECTION Dimensions_DBD_3_rep_MonMetrics /*+createtype(D)*/
(
 id ENCODING RLE, 
 name ENCODING AUTO, 
 value ENCODING AUTO
)
AS
 SELECT dimension_set_id, 
        name, 
        value
 FROM MonMetrics.Dimensions 
 ORDER BY dimension_set_id,
          name
UNSEGMENTED ALL NODES;

CREATE PROJECTION DefinitionDimensions_DBD_4_rep_MonMetrics /*+createtype(D)*/
(
 id ENCODING RLE, 
 definition_id,
 dimension_set_id
)
AS
 SELECT id, 
        definition_id, 
        dimension_set_id
 FROM MonMetrics.DefinitionDimensions 
 ORDER BY definition_id,
          dimension_set_id,
          id
UNSEGMENTED ALL NODES;

select refresh('MonMetrics.Measurements, MonMetrics.Definitions, MonMetrics.Dimensions, MonMetrics.DefinitionDimensions');
