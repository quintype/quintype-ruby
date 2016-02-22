module QuintypeLoader
  if defined?(Rails)
    require 'quintype/engine'
  else
    require 'quintype/api'
  end
end
