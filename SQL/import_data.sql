\copy paises(nomepais) 
    FROM '/home/luisdantas/Repo/LabBD/F1_Database/Data/countries.csv' 
    DELIMITER ',' 
    CSV HEADER;

\copy status(descricao) 
    FROM '/home/luisdantas/Repo/LabBD/F1_Database/Data/status.csv' 
    DELIMITER ',' 
    CSV HEADER;