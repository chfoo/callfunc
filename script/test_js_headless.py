import os.path
import subprocess
import sys
import os
import signal

from selenium import webdriver
from selenium.webdriver.chrome.options import Options

def main():
    script_dir = os.path.dirname(__file__)
    root_dir = os.path.join(script_dir, '..')
    html_path = os.path.join(root_dir, 'test.html')
    server_process = subprocess.Popen(['emrun', '--no_browser', '--no_emrun_detect', html_path])

    chrome_options = Options()
    chrome_options.add_argument("--headless")

    driver_path = os.path.join(root_dir, 'out', 'chromedriver')
    browser = webdriver.Chrome(options=chrome_options, executable_path=driver_path)
    test_result = False

    try:
        browser.get('http://localhost:6931/test.html')

        header_element = browser.find_element_by_css_selector(".header")
        print(header_element.text)

        summary_element = browser.find_element_by_css_selector(".headerinfo")
        print(summary_element.text)

        if header_element.text == 'TEST OK':
            test_result = True

    finally:
        os.killpg(os.getpgid(server_process.pid), signal.SIGTERM)
        server_process.wait()
        browser.quit()

        if not test_result:
            sys.exit(1)

if __name__ == '__main__':
    main()
