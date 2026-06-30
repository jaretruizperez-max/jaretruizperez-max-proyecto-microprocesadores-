

DATABASES = {
    'default': {
        'ENGINE': 'mssql',
        'NAME': 'ReconocimientoFacial',
        'HOST': r'(localdb)\mafis',
        'OPTIONS': {
            'driver': 'ODBC Driver 17 for SQL Server',
            'trusted_connection': 'yes',
        },
    }
}    