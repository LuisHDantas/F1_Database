-- IMPORTING DATA FROM THE COUNTRIES.CSV FILE

CREATE TEMP TABLE staging_countries (
    id VARCHAR(100),
    code CHAR(2),
    nomepais VARCHAR(60) PRIMARY KEY,
    continent VARCHAR(2),
    link VARCHAR(1000),
    keywords VARCHAR(1000)
);

\copy staging_countries FROM '/home/luisdantas/Repo/LabBD/F1_Database/Data/countries.csv' DELIMITER ',' CSV HEADER;

INSERT INTO paises(nomepais) SELECT nomepais FROM staging_countries;


-- IMPORTING DATA FROM THE STATUS.CSV FILE

CREATE TEMP TABLE staging_status (
    id SMALLINT,
    descricao VARCHAR(100) PRIMARY KEY
);

\copy staging_status FROM '/home/luisdantas/Repo/LabBD/F1_Database/Data/status.csv' DELIMITER ',' CSV HEADER;

INSERT INTO status(descricao) SELECT descricao FROM staging_status;


-- IMPORTING DATA FROM THE CONSTRUCTORS.CSV FILE

CREATE TEMP TABLE staging_constructors (
    id SMALLINT PRIMARY KEY,
    ref VARCHAR(100),
    nomeconstrutor VARCHAR(100),
    nacionalidade VARCHAR(60),
    url VARCHAR(1000)
);

\copy staging_constructors FROM '/home/luisdantas/Repo/LabBD/F1_Database/Data/constructors.csv' DELIMITER ',' CSV HEADER;

INSERT INTO Construtores(ID, Nome, NomePais) SELECT id, nomeconstrutor, nacionalidade FROM staging_constructors;



-- IMPORTING DATA FROM THE DRIVERS.CSV FILE

CREATE TEMP TABLE staging_drivers (
    id SMALLINT PRIMARY KEY,
    ref VARCHAR(100),
    numero SMALLINT,
    codigo CHAR(3),
    nome VARCHAR(100),
    sobrenome VARCHAR(100),
    datanascimento DATE,
    nacionalidade VARCHAR(60),
    url VARCHAR(1000)
);

\copy staging_drivers FROM '/home/luisdantas/Repo/LabBD/F1_Database/Data/drivers.csv' DELIMITER ',' CSV HEADER NULL '\N';

INSERT INTO Pilotos(Nome, Numero, Codigo, DataNascimento, NomePais)
    SELECT nome || ' ' || sobrenome, numero, codigo, datanascimento, nacionalidade FROM staging_drivers;



-- IMPORTING DATA FROM CITIES FILE

CREATE TABLE staging_cities (
    id VARCHAR(100),                 -- Column 1: Unique ID
    name TEXT,                  -- Column 2: Name of the city or location
    name_alt TEXT,              -- Column 3: Alternative name or transliteration
    name_variants TEXT,         -- Column 4: Name variants or translations
    latitude NUMERIC,           -- Column 5: Latitude
    longitude NUMERIC,          -- Column 6: Longitude
    feature_class CHAR(1),      -- Column 7: Feature class (e.g., "P" for populated places)
    feature_code VARCHAR(100),   -- Column 8: Feature code (e.g., "PPLC" for capital)
    country_code CHAR(2),       -- Column 9: ISO country code (e.g., "US" for United States)
    region_code VARCHAR(100),    -- Column 10: Administrative region code
    admin_code1 VARCHAR(100),    -- Column 11: First level administrative division (e.g., state/province)
    admin_code2 VARCHAR(100),    -- Column 12: Second level administrative division (e.g., county)
    admin_code3 VARCHAR(100),    -- Column 13: Third level administrative division (if available)
    admin_code4 VARCHAR(100),    -- Column 14: Additional admin code (if applicable)
    population INTEGER,         -- Column 15: Population
    elevation VARCHAR(100),          -- Column 16: Elevation (in meters)
    dem VARCHAR(100),                -- Column 17: Digital Elevation Model (DEM), elevation
    timezone TEXT,              -- Column 18: Timezone (e.g., "Europe/Andorra")
    modification_date DATE      -- Column 19: Last modification date (e.g., "2008-10-15")
);


\copy staging_cities FROM '/home/luisdantas/Repo/LabBD/F1_Database/Data/Cities15000.tsv' WITH (FORMAT csv, DELIMITER E'\t', NULL '\n');

DELETE FROM staging_cities WHERE latitude = 55.71667 AND longitude = 37.41667; -- Deleting duplicate entry (City was irrelevant for the database, so deleted both)

INSERT INTO Cidades(Latitude, Longitude, Nome, Populacao, NomePais)
    SELECT latitude, longitude, name, population, country_code FROM staging_cities
    ON CONFLICT(Nome, NomePais) DO NOTHING;



-- IMPORTING DATA FROM CIRCUITS.CSV FILE

CREATE TEMP TABLE staging_circuits (
    id SMALLINT PRIMARY KEY,
    ref VARCHAR(100),
    nome VARCHAR(1000),
    localizacao VARCHAR(1000),
    pais VARCHAR(60),
    latitude FLOAT,
    longitude FLOAT,
    altitude SMALLINT,
    url VARCHAR(1000)
);

\copy staging_circuits FROM '/home/luisdantas/Repo/LabBD/F1_Database/Data/circuits.csv' DELIMITER ',' CSV HEADER;

INSERT INTO Circuitos(Nome, Latitude, Longitude, NomeResum, LatitudeCidade, LongitudeCidade)
    SELECT 
        sc.nome, 
        sc.latitude, 
        sc.longitude, 
        sc.nome, 
        sc.latitude,    -- Não temos os dados de forma adequada para a cidade, então usamos a latitude e longitude do circuito
        sc.longitude
    FROM staging_circuits sc
    -- JOIN Cidades c ON c.nome = sc.localizacao
    ON CONFLICT (Nome) DO NOTHING;


-- IMPORTING AIRPORTS DATA FROM THE AIRPORTS.CSV FILE

CREATE TEMP TABLE staging_airports (
    id VARCHAR(100),                 
    ident VARCHAR(100),
    type VARCHAR(100),
    name TEXT,
    latitude NUMERIC,
    longitude NUMERIC,
    elevation DOUBLE PRECISION,
    continent VARCHAR(100),
    iso_country CHAR(2),
    iso_region VARCHAR(100),
    municipality VARCHAR(100),
    scheduled_service VARCHAR(100),
    gps_code VARCHAR(100),
    iata_code VARCHAR(100),
    local_code VARCHAR(100),
    home_link VARCHAR(1000),
    wikipedia_link VARCHAR(1000),
    keywords VARCHAR(1000)
);

\copy staging_airports FROM '/home/luisdantas/Repo/LabBD/F1_Database/Data/airports.csv' DELIMITER ',' CSV HEADER;

INSERT INTO Aeroportos(ICAO, IATA, Nome, Latitude, Longitude, Altitude, LatitudeCidade, LongitudeCidade, NomePais)
    SELECT 
        sa.ident, 
        sa.iata_code, 
        sa.name, 
        sa.latitude, 
        sa.longitude, 
        sa.elevation,
        c.latitude, 
        c.longitude, 
        sa.iso_country 
    FROM staging_airports sa
    JOIN Cidades c ON c.nome = sa.municipality AND c.NomePais = sa.iso_country;


-- IMPORTING DATA FROM RACES.CSV FILE

CREATE TEMP TABLE staging_races (
    id SMALLINT PRIMARY KEY,
    ano SMALLINT,
    rodada SMALLINT,
    idcircuito SMALLINT,
    nomecorrida VARCHAR(100),
    datacorrida DATE,
    hora TIME,
    url VARCHAR(100),
    fp1_date DATE,
    fp1_time TIME,
    fp2_date DATE,
    fp2_time TIME,
    fp3_date DATE,
    fp3_time TIME,
    quali_date DATE,
    quali_time TIME,
    sprint_date DATE,
    sprint_time TIME
);

\copy staging_races FROM '/home/luisdantas/Repo/LabBD/F1_Database/Data/races.csv' DELIMITER ',' CSV HEADER NULL '\N';

INSERT INTO Corridas(ID, NomeCircuito, Ano, Rodada, Temporada, Nome, Hora, DataCorrida)
    SELECT id, (SELECT nome FROM staging_circuits WHERE id = staging_races.idcircuito), ano, rodada, ano, nomecorrida, hora, datacorrida FROM staging_races;


-- IMPORTING DATA FROM VOLTAS.CSV FILE

CREATE TEMP TABLE staging_laps (
    raceID SMALLINT,
    driverID SMALLINT,
    lap SMALLINT,
    position SMALLINT,
    time TIME,
    milliseconds NUMERIC
);

\copy staging_laps FROM '/home/luisdantas/Repo/LabBD/F1_Database/Data/lap_Times.csv' DELIMITER ',' CSV HEADER;

INSERT INTO Voltas(IDCorrida, NomeCircuito, NomePiloto, NrVolta, Posicao, TempoMin, TempoMs, Velocidade)
    SELECT raceID, (SELECT NomeCircuito FROM Corridas WHERE ID = raceID), (SELECT Nome || ' ' || Sobrenome FROM staging_drivers WHERE ID = driverID), lap, position, time, milliseconds, NULL FROM staging_laps
    ON CONFLICT (IDCorrida, NomeCircuito, NomePiloto, NrVolta) DO NOTHING;


-- IMPORTING DATA FROM PITSTOPS.CSV FILE

CREATE TEMP TABLE staging_pitstops (
    raceID SMALLINT,
    driverID SMALLINT,
    stop SMALLINT,
    lap SMALLINT,
    time TIME,
    duration VARCHAR(100), -- Tivemos que mudar para VARCHAR pois a coluna tem valores como "1:02.123" (Mal formatado)
    milliseconds VARCHAR(100)
);

\copy staging_pitstops FROM '/home/luisdantas/Repo/LabBD/F1_Database/Data/pit_Stops.csv' DELIMITER ',' CSV HEADER;

INSERT INTO PitStop(IDCorrida, NomeCircuito, NomePiloto, NrVolta, Numero, Tempo, DuracaoMin, DuracaoMs) 
    SELECT raceID, (SELECT NomeCircuito FROM Corridas WHERE ID = raceID), (SELECT Nome || ' ' || Sobrenome FROM staging_drivers WHERE ID = driverID), lap, stop, time, duration, milliseconds FROM staging_pitstops
    ON CONFLICT (IDCorrida, NomeCircuito, NomePiloto, NrVolta, Numero) DO NOTHING;



-- IMPORTING DATA FROM QUALIFYING.CSV FILE

CREATE TEMP TABLE staging_qualifying (
    qualifyID SMALLINT,
    raceID SMALLINT,
    driverID SMALLINT,
    constructorID SMALLINT,
    number SMALLINT,
    position SMALLINT,
    q1 TIME,
    q2 TIME,
    q3 TIME
);

\copy staging_qualifying FROM '/home/luisdantas/Repo/LabBD/F1_Database/Data/qualifying.csv' DELIMITER ',' CSV HEADER;

INSERT INTO Qualifica(IDCorrida, NomeCircuito, NomePiloto, IDConstrutor, TempoQ1, TempoQ2, TempoQ3, PosicaoGrid)
    SELECT raceID, (SELECT NomeCircuito FROM Corridas WHERE ID = raceID), (SELECT Nome || ' ' || Sobrenome FROM staging_drivers WHERE ID = driverID), constructorID, q1, q2, q3, position FROM staging_qualifying
    ON CONFLICT (IDCorrida, NomeCircuito, NomePiloto) DO NOTHING;

-- IMPORTING DATA FROM DRIVERS STANDINGS FILE

CREATE TEMP TABLE staging_driver_standings (
    id INTEGER,
    raceID SMALLINT,
    driverID SMALLINT,
    points NUMERIC,
    position SMALLINT,
    positionText VARCHAR(100),
    wins SMALLINT
);

\copy staging_driver_standings FROM '/home/luisdantas/Repo/LabBD/F1_Database/Data/driver_Standings.csv' DELIMITER ',' CSV HEADER;

INSERT INTO ClassificacaoPilotos(IDCorrida, NomeCircuito, NomePiloto, Pontuacao, Posicao, Vitorias)
    SELECT raceID, (SELECT NomeCircuito FROM Corridas WHERE ID = raceID), (SELECT Nome || ' ' || Sobrenome FROM staging_drivers WHERE ID = driverID), points, position, wins FROM staging_driver_standings
    ON CONFLICT (IDCorrida, NomeCircuito, NomePiloto) DO NOTHING;


-- IMPORTING DATA FROM RESULTS.CSV FILE

CREATE TEMP TABLE staging_results (
    resultID SMALLINT,
    raceID SMALLINT,
    driverID SMALLINT,
    constructorID SMALLINT,
    number SMALLINT,
    grid SMALLINT,
    position SMALLINT,
    positionText VARCHAR(100),
    positionOrder SMALLINT,
    points NUMERIC,
    laps SMALLINT,
    time VARCHAR(100),
    milliseconds NUMERIC,
    fastestLap SMALLINT,
    rank SMALLINT,
    fastestLapTime TIME,
    fastestLapSpeed NUMERIC,
    statusID SMALLINT
);

\copy staging_results FROM '/home/luisdantas/Repo/LabBD/F1_Database/Data/results.csv' DELIMITER ',' CSV HEADER NULL '\N';

INSERT INTO Resultados(IDCorrida, NomeCircuito, NomePiloto, IDConstrutor, PosicaoGrid, PosicaoFinal, QTDPontos, QTDVoltas, TempoHrs, TempoMs, DescricaoStatus)
    SELECT raceID, (SELECT NomeCircuito FROM Corridas WHERE ID = raceID), (SELECT Nome || ' ' || Sobrenome FROM staging_drivers WHERE ID = driverID), constructorID, grid, position, points, laps, time, milliseconds, (SELECT descricao FROM staging_status WHERE id = statusID) FROM staging_results
    ON CONFLICT (IDCorrida, NomeCircuito, NomePiloto) DO NOTHING;

DROP TABLE IF EXISTS staging_countries;
DROP TABLE IF EXISTS staging_status;
DROP TABLE IF EXISTS staging_constructors;
DROP TABLE IF EXISTS staging_drivers;
DROP TABLE IF EXISTS staging_circuits;
DROP TABLE IF EXISTS staging_airports;
DROP TABLE IF EXISTS staging_races;
DROP TABLE IF EXISTS staging_laps;
DROP TABLE IF EXISTS staging_pitstops;
DROP TABLE IF EXISTS staging_qualifying;
DROP TABLE IF EXISTS staging_driver_standings;
DROP TABLE IF EXISTS staging_results;