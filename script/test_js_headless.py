import os.path
import subprocess
import sys
import os
import atexit
import signal

from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By


def main():
    print('Starting server...', file=sys.stderr)

    script_dir = os.path.dirname(__file__)
    root_dir = os.path.join(script_dir, '..')
    html_path = os.path.join(root_dir, 'test.html')
    server_process = subprocess.Popen(['emrun', '--no_browser', '--no_emrun_detect', html_path], preexec_fn=os.setsid)

    print('Starting Chrome...', file=sys.stderr)

    chrome_options = Options()
    chrome_options.add_argument("--headless")

    if "CHROMEWEBDRIVER" in os.environ:
        driver_path = os.path.join(os.environ["CHROMEWEBDRIVER"], 'chromedriver')
    else:
        driver_path = os.path.join(root_dir, 'out', 'chromedriver')

    browser = webdriver.Chrome(options=chrome_options, executable_path=driver_path)
    test_result = False

    def cleanup_server():
        os.killpg(os.getpgid(server_process.pid), signal.SIGTERM)
        server_process.wait()

    def cleanup_browser():
        browser.quit()

    atexit.register(cleanup_server)
    atexit.register(cleanup_browser)

    print('Loading page...', file=sys.stderr)
    browser.get('http://localhost:6931/test.html')
    print('Loaded.', file=sys.stderr)

    try:
        header_element = WebDriverWait(browser, 10).until(
            EC.presence_of_element_located((By.CSS_SELECTOR, ".header"))
        )
        print(header_element.text, file=sys.stderr)

        summary_element = browser.find_element_by_css_selector(".headerinfo")
        print(summary_element.text, file=sys.stderr)
    except NoSuchElementException:
        print('Failed to find element', file=sys.stderr)
        body_element = browser.find_element_by_tag_name('body')
        print(body_element.text[:1000], file=sys.stderr)

    if header_element.text == 'TEST OK':
        test_result = True

    print('Cleanup', file=sys.stderr)
    cleanup_browser()
    cleanup_server()

    print('Done', file=sys.stderr)

    if not test_result:
        sys.exit(1)


if __name__ == '__main__':
    main()
