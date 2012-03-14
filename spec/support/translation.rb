def create_translation(key,value='value',locale='en')
   I18n.backend.store_translations(locale, {key => value}, :escape => false)
end
