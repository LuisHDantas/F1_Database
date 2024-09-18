DROP TABLE IF EXISTS Cidades CASCADE;
CREATE TABLE Cidades (
        Latitude DOUBLE PRECISION,
        Longitude DOUBLE PRECISION,
        Nome VARCHAR(60) NOT NULL,
        Populacao NUMERIC(11) NOT NULL,
        NomePais VARCHAR(60) NOT NULL,
        PRIMARY KEY (Latitude, Longitude),
        FOREIGN KEY (NomePais) 
                REFERENCES Paises (NomePais) 
                        ON UPDATE CASCADE,
        CHECK (Populacao >= 0),
        UNIQUE (Nome, NomePais)
);

DROP TABLE IF EXISTS Aeroportos;
CREATE TABLE Aeroportos (
        ICAO VARCHAR(10) PRIMARY KEY,
        IATA CHAR(3),
        Nome VARCHAR(100) NOT NULL,
        Latitude DOUBLE PRECISION NOT NULL,
        Longitude DOUBLE PRECISION NOT NULL,
        Altitude DOUBLE PRECISION,
        LatitudeCidade DOUBLE PRECISION NOT NULL,
        LongitudeCidade DOUBLE PRECISION NOT NULL,
        NomePais VARCHAR(60) NOT NULL,
        -- FOREIGN KEY (NomePais)
        --         REFERENCES Paises (NomePais)
        --                 ON UPDATE CASCADE,
        FOREIGN KEY (LatitudeCidade, LongitudeCidade)
                REFERENCES Cidades (Latitude, Longitude)
                        ON UPDATE CASCADE
);

DROP TABLE IF EXISTS Circuitos CASCADE;
CREATE TABLE Circuitos (
        Nome VARCHAR(100) PRIMARY KEY,
        Latitude DOUBLE PRECISION NOT NULL,
        Longitude DOUBLE PRECISION NOT NULL,
        NomeResum VARCHAR(40),
        LatitudeCidade DOUBLE PRECISION NOT NULL,
        LongitudeCidade DOUBLE PRECISION NOT NULL
        -- FOREIGN KEY (LatitudeCidade, LongitudeCidade)
        --         REFERENCES Cidades (Latitude, Longitude)
        --                 ON UPDATE CASCADE
);

DROP TABLE IF EXISTS Corridas CASCADE;
CREATE TABLE Corridas (
        ID SERIAL,
        NomeCircuito VARCHAR(100),
        Ano SMALLINT NOT NULL,
        Rodada SMALLINT NOT NULL,
        Temporada SMALLINT NOT NULL,
        Nome VARCHAR(100) NOT NULL,
        Hora TIME,
        DataCorrida DATE NOT NULL,
        PRIMARY KEY (ID, NomeCircuito),
        FOREIGN KEY (NomeCircuito)
                REFERENCES Circuitos (Nome)
                        ON UPDATE CASCADE,
        CHECK (Rodada > 0),
        CHECK (Temporada > 0)
);

DROP TABLE IF EXISTS Construtores CASCADE;
CREATE TABLE Construtores (
        ID SERIAL PRIMARY KEY,
        Nome VARCHAR(100) NOT NULL,
        NomePais VARCHAR(60) NOT NULL,
        FOREIGN KEY (NomePais)
                REFERENCES Paises (NomePais)
                        ON UPDATE CASCADE
);

DROP TABLE IF EXISTS Pilotos CASCADE;
CREATE TABLE Pilotos (
        Nome VARCHAR(100) PRIMARY KEY,
        Numero SMALLINT,
        Codigo CHAR(3),
        DataNascimento DATE NOT NULL,
        NomePais VARCHAR(60) NOT NULL,
        FOREIGN KEY (NomePais)
                REFERENCES Paises (NomePais)
                        ON UPDATE CASCADE,
        CHECK (Numero >= 0)
);

DROP TABLE IF EXISTS ClassificacaoPilotos;
CREATE TABLE ClassificacaoPilotos (
        IDCorrida INTEGER,
        NomeCircuito VARCHAR(100),
        NomePiloto VARCHAR(100),
        Pontuacao SMALLINT NOT NULL,
        Posicao SMALLINT NOT NULL,
        Vitorias SMALLINT NOT NULL,
        PRIMARY KEY (IDCorrida, NomeCircuito, NomePiloto),
        FOREIGN KEY (IDCorrida, NomeCircuito)
                REFERENCES Corridas (ID, NomeCircuito)
                        ON UPDATE CASCADE,
        FOREIGN KEY (NomePiloto)
                REFERENCES Pilotos (Nome)
                        ON UPDATE CASCADE,
        CHECK (Pontuacao >= 0),
        CHECK (Posicao > 0)
);

DROP TABLE IF EXISTS Qualifica;
CREATE TABLE Qualifica (
        IDCorrida INTEGER,
        NomeCircuito VARCHAR(100),
        NomePiloto VARCHAR(100),
        IDConstrutor INTEGER NOT NULL,
        TempoQ1 TIME,
        TempoQ2 TIME,
        TempoQ3 TIME,
        PosicaoGrid SMALLINT NOT NULL,
        PRIMARY KEY (IDCorrida, NomeCircuito, NomePiloto),
        FOREIGN KEY (IDCorrida, NomeCircuito)
                REFERENCES Corridas (ID, NomeCircuito)
                        ON UPDATE CASCADE,
        FOREIGN KEY (NomePiloto)
                REFERENCES Pilotos (Nome)
                        ON UPDATE CASCADE,
        FOREIGN KEY (IDConstrutor)
                REFERENCES Construtores (ID)
                        ON UPDATE CASCADE,
        CHECK (PosicaoGrid > 0)
);

DROP TABLE IF EXISTS Resultados;
CREATE TABLE Resultados (
        IDCorrida INTEGER,
        NomeCircuito VARCHAR(100),
        NomePiloto VARCHAR(100),
        IDConstrutor INTEGER NOT NULL,
        PosicaoGrid SMALLINT,
        PosicaoFinal SMALLINT,
        QTDPontos SMALLINT NOT NULL,
        QTDVoltas SMALLINT NOT NULL,
        TempoHrs VARCHAR(100),
        TempoMs NUMERIC,
        DescricaoStatus VARCHAR(100) NOT NULL,
        PRIMARY KEY (IDCorrida, NomeCircuito, NomePiloto),
        FOREIGN KEY (IDCorrida, NomeCircuito)
                REFERENCES Corridas (ID, NomeCircuito)
                        ON UPDATE CASCADE,
        FOREIGN KEY (NomePiloto)
                REFERENCES Pilotos (Nome)
                        ON UPDATE CASCADE,
        FOREIGN KEY (IDConstrutor)
                REFERENCES Construtores (ID)
                        ON UPDATE CASCADE,
        FOREIGN KEY (DescricaoStatus)
                REFERENCES Status (Descricao)
                        ON UPDATE CASCADE,
        CHECK (QTDPontos >= 0),
        CHECK (QTDVoltas >= 0)
);

DROP TABLE IF EXISTS Status CASCADE;
CREATE TABLE Status (
        Descricao VARCHAR(100) PRIMARY KEY
);

DROP TABLE IF EXISTS Paises CASCADE;
CREATE TABLE Paises (
        NomePais VARCHAR(60) PRIMARY KEY
);

DROP TABLE IF EXISTS Voltas CASCADE;
CREATE TABLE Voltas (
        IDCorrida INTEGER,
        NomeCircuito VARCHAR(100),
        NomePiloto VARCHAR(100),
        NrVolta SMALLINT,
        Posicao SMALLINT NOT NULL,
        TempoMin TIME NOT NULL,
        TempoMs NUMERIC NOT NULL,
        Velocidade DOUBLE PRECISION,
        PRIMARY KEY (IDCorrida, NomeCircuito, NomePiloto, NrVolta),
        FOREIGN KEY (IDCorrida, NomeCircuito)
                REFERENCES Corridas (ID, NomeCircuito)
                        ON UPDATE CASCADE,
        FOREIGN KEY (NomePiloto)
                REFERENCES Pilotos (Nome)
                        ON UPDATE CASCADE,
        CHECK (NrVolta > 0),
        CHECK (Posicao > 0)
);

DROP TABLE IF EXISTS PitStop CASCADE;
CREATE TABLE PitStop (
        IDCorrida INTEGER,
        NomeCircuito VARCHAR(100),
        NomePiloto VARCHAR(100),
        NrVolta SMALLINT,
        Numero SMALLINT,
        Tempo TIME NOT NULL,
        DuracaoMin VARCHAR(100) NOT NULL,
        DuracaoMs VARCHAR(100) NOT NULL,
        PRIMARY KEY (IDCorrida, NomeCircuito, NomePiloto, NrVolta, Numero),
        FOREIGN KEY (IDCorrida, NomeCircuito, NomePiloto, NrVolta)
                REFERENCES Voltas (IDCorrida, NomeCircuito, NomePiloto, NrVolta)
                        ON UPDATE CASCADE,
        CHECK (NrVolta > 0),
        CHECK (Numero > 0)
);

