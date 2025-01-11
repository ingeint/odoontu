import pyDolarVenezuela as pdv

monitor = pdv.Monitor()

# Obtener los valores de todos los monitores
values = monitor.get_value_monitors()
print(values)

# Obtener el valor del dólar en EnParaleloVzla
get_value_enparalelovzla = monitor.get_value_monitors(monitor_code='enparalelovzla', name_property='price', prettify=True)

# Obtener la ultima actualizacion del dólar en Binance
get_value_binance = monitor.get_value_monitors(monitor_code='binance', name_property='last_update', prettify=False)
