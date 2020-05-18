require "selenium-webdriver"
driver = Selenium::WebDriver.for(
  :chrome,
  options: { browser: :remote, url: "http://host.docker.internal:9515" },
)
driver.get "https://avdi.codes"
