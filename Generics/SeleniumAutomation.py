from selenium import webdriver
import kiteconnect
driver = webdriver.Chrome("C:/Python/phantomjs/bin/chromedriver.exe")
#driver = webdriver.PhantomJS()
#driver.get("http://google.com")

# This will get the initial html - before javascript
#html1 = driver.page_source

# This will get the html after on-load javascript
#html2 = driver.execute_script("return document.documentElement.innerHTML;")
#print(html1)
browser = webdriver.Chrome()
browser.get('https://google.com')