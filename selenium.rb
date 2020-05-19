require "selenium-webdriver"
driver = Selenium::WebDriver.for(:remote, url: "http://host.docker.internal:9515")
driver.get "https://avdi.codes"
