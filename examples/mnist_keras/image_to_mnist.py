import cv2
import numpy as np
import base64
def base64_to_cv2_img(uri):
    encoded_data = uri.split(',')[1]
    print(encoded_data)
    nparr = np.fromstring(base64.b64decode(encoded_data), np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    return img

data_uri = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAEVklEQVR4Xu2bTagNcRjGf1cklkospYiwkg02ys5XUT5KPiIrxcoa2VhJlsKVEhGRNUqxsVIU+djbK/nuX1fuveYcc8+4531nnue//s953+d5fvPOOTNzRvCSdmBEWr3FYwDEITAABkDcAXH5ngAGQNwBcfmeAAZA3AFx+Z4ABkDcAXH5ngAGQNwBcfmeAAZA3AFx+Z4ABkDcAXH5ngAGQNwBcfmeAAZA3AFx+Z4ABkDcAXH5ngAGQNwBcfmeAAZA3AFx+Z4ABkDcAXH5ngAGQNwBcfmeAAZA3AFx+Z4ABkDcAXH5ngAGQNwBcfmeAAZA3AFx+Z4ABkDcAXH5XZ0A84C9wHngKnAaeC+edaX8LgKwEHgBzB+n+AewHHhjCCY60EUAjgIXKoK+Bew0ALoAFOVdBL4R0100ZBHwoYcrXdRrACY5UK71rwxAPS66dkYcB871kd41vfVSFjCk31n/W/5TYF1jxzr2AV04Iw4AV2rksgV4UGOf1Ja2A7AHuF4jsTXA8xr75La0GYC5wKd/JHYKOCmX6hQEtxmAL8CsPlpXAi+n4IXk1rYCcAI42yOxQ8BlyTQHEN1GADYAD3toPQiMDuCD7CFtA6D0Wx7sVK1ySZgtm+SAwtsGwDtgcQ+tc4DPA/oge1ibANgB3O6R1G7gpmyKDYS3BYB+o7/c91/RwAPpQ9sCwGtgaY+kZgA/pVNsIL4NAJRrfrn2V61yWbjTQL/8oW0A4CswsyKpt8AS+QQbGpAdgFVj7/dVyfTobxh+OTw7APeB8hRv8toO3P0P+uU/IjsA0/Xl7tLY7eLyjoD0UgVgcujPgH1A+V4htQzAxLjLPYVtSiBkB6C8wbMp4JR8BBxW+DdRdgDWA08CACglJf5NlB2AEsRa4AiwPwCEx0B5/NzZ1QYApsP8jcAxYHONDy9vHX2rsa+VW1QBGB/WauDa2J9Hq0Is3wXKz8ZOLgPwJ9atwL2KlMvl52In02/BncBh+74LuDGuaLkvsAz4PuxGhlXPE+BvpxcAZ4DyEKq8Uv5xWGFE1DEAEa4nqmkAEoUR0YoBiHA9UU0DkCiMiFYMQITriWoagERhRLRiACJcT1TTACQKI6IVAxDheqKaBiBRGBGtGIAI1xPVNACJwohoxQBEuJ6opgFIFEZEKwYgwvVENQ1AojAiWjEAEa4nqmkAEoUR0YoBiHA9UU0DkCiMiFYMQITriWoagERhRLRiACJcT1TTACQKI6IVAxDheqKaBiBRGBGtGIAI1xPVNACJwohoxQBEuJ6opgFIFEZEKwYgwvVENQ1AojAiWjEAEa4nqmkAEoUR0YoBiHA9UU0DkCiMiFYMQITriWoagERhRLRiACJcT1TTACQKI6IVAxDheqKaBiBRGBGtGIAI1xPVNACJwohoxQBEuJ6opgFIFEZEKwYgwvVENQ1AojAiWjEAEa4nqmkAEoUR0YoBiHA9UU0DkCiMiFYMQITriWr+Av/dSYHGBYwbAAAAAElFTkSuQmCC"
img = base64_to_cv2_img(data_uri)
