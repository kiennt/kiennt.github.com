+++
author = "kiennt"
date = "2014-03-28T00:00:00Z"
title = "Hacking pinterest android app"
url = "/blog/2014/03/28/hacking-pinterest.html"
tags = ["hacking"]
comments = true
share = true
+++

This article show a way to get private key for Pinterest android app. This article is inspired from this one http://blog.will3942.com/reverse-engineering-instagram. This method was tested on Pinterest app version 2.4.2 and was done from MacOSX.

<!--more-->

## Preparation

+ Download Android SDK from http://developer.android.com/sdk/index.html

  Unzip the file we just downloaded. We will see 2 folder: `eclipse`, `sdk`

  In `sdk` folders, there are `build-tools`, `extras`, `platform-tools`, `system-images`, `tools`

  Modify $PATH environment variable

```python
$> echo "export PATH=$PATH:/DEVELOPMENT/ANDROID/sdk/tools/:/DEVELOPMENT/ANDROID/sdk/platform-tools/:/DEVELOPMENT/ANDROID/sdk/build-tools/android-4.4.2/" >> ~/.bash_profile
```

+ Download [apktools](https://code.google.com/p/android-apktool/).

  In this article, we tested with Mac OSX 10.8, so we use [apktool.1.5.2](http://code.google.com/p/android-apktool/downloads/detail?name=apktool1.5.2.tar.bz2)

+ Set up new android virtual device

```bash
  $> android avd
```

  ![android-create-image1](/images/hacking-pinterest/android-create-image1.png)
  ![android-create-image2](/images/hacking-pinterest/android-create-image2.png)

  Start new virtual device we just created

  ![android-virtual-device](/images/hacking-pinterest/android-virtual-device.png)

+ Download pinterest.2.4.2.apk from http://apkandroid.blogspot.com/2014/02/pinterest-242-apk.html


## Hacking

+ Using apktool to decompile pinterest.2.4.2.apk to smali

```bash
  $> java -jar /DEVELOPMENT/ANDROID/apktool1.5.2/apktool.jar d pinterest.2.4.2.apk
```

  ![pinterest-smali](/images/hacking-pinterest/pinterest-smali-folder.png)

  All the code will located in `smali` folder

  The code to get private key is located in `smali/com/pinterest/base/Application.smali`

+ There are 2 function we will need to hack

  The first one is `getClientID` at `smali/com/pinterest/base/Application.smali:78`

```smali
    .method public static final getClientID()Ljava/lang/String;
        .locals 1

        .prologue
        .line 268
        sget-object v0, Lcom/pinterest/api/a;->d:Ljava/lang/String;
        return-object v0
    .end method
```

  We modify it to

```smali
    .method public static final getClientID()Ljava/lang/String;
        .locals 2

        .prologue
        .line 268
        sget-object v0, Lcom/pinterest/api/a;->d:Ljava/lang/String;
        const-string v1, "LOGGING: CLIENT ID"
        invoke-static {v1, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

        return-object v0
    .end method
```

  NOTE: because we use one more variable v1, so we will need to modify `.locals 1` to `.locals 2`

  The second function is `getClientSecret` at `smali/com/pinterest/base/Application.smali:89`

  We also add a logging to print out the value. Modify `.locals 6` to `.locals 7` and modify end of function like this

```smali
    .line 305
    invoke-virtual {v0}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

    move-result-object v0

    const-string v6, "LOGGING: CLIENT SECRET"
    invoke-static {v6, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    goto :goto_0
.end method
```

+ Using apktool to recompile this code

```bash
  $> java -jar /DEVELOPMENT/ANDROID/apktool1.5.2/apktool.jar b pinterest.2.4.2
```

  The new apk file is located at pinterest.2.4.2/dist/pinterest.2.4.2

+ Using keytool to generate an key

```bash
  $> cd pinterest.2.4.2/dist
  $> keytool -genkey -v -keystore android.keystore -alias android -keyalg RSA -keysize 2048 -validity 10000
```

  NOTE, we set keystore password and key password is `android` (https://developer.android.com/tools/publishing/app-signing.html#setup). I am not sure this one is required

+ Sign new apk app

```bash
  $> jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore android.keystore pinterest.2.4.2.apk android
```

+ Verify apk

```bash
  $> zipalign -f -v 4 pinterest.2.4.2.apk pinterest.apk
```

+ Install apk app on emulator

```bash
  $> adb install pinterest.apk
```

+ Check log of emulator

```bash
  $> adb logcat | grep LOGGING
```

+ Now in emulator, we only need to start pinterest app

  The client ID and client secret will be show in log like this

```bash
    D/LOGGING: CLIENT ID( 1549): 1431602
    D/LOGGING: CLIENT SECRET( 1549): 492124fd20e80e0f678f7a03344875f9b6234e2b
```

## Get pinterest algorithm to generate signature

After get client id and client secret, I want to know about how  Pinterest generate their signature

+ Firstly, find out where they code signature generation function


```bash
  $> cd pinterest.2.4.2/smali/com/pinterest
  $> grep -r "oauth_signature" .
```

  The file is `api/a/i.smali`

+ Let look at how pinterest implement there algorithm

```smali
    .method private static a(Ljava/lang/String;Ljava/lang/String;Ljava/util/Map;)Ljava/lang/String;
        .locals 9
        .parameter
        .parameter
        .parameter

        .prologue
        const/4 v8, 0x1

        const/4 v7, 0x0

        .line 315
        .line 317
        :try_start_0
        const-string v0, "\\?"

        invoke-virtual {p1, v0}, Ljava/lang/String;->split(Ljava/lang/String;)[Ljava/lang/String;

        move-result-object v0

        const/4 v1, 0x0

        aget-object v0, v0, v1

        const-string v1, "UTF-8"

        invoke-static {v0, v1}, Ljava/net/URLEncoder;->encode(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;
        :try_end_0
        .catch Ljava/io/UnsupportedEncodingException; {:try_start_0 .. :try_end_0} :catch_1

        move-result-object v0

        .line 322
        :goto_0
        new-instance v1, Ljava/lang/StringBuilder;

        invoke-direct {v1}, Ljava/lang/StringBuilder;-><init>()V

        .line 323
        invoke-virtual {v1, p0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

        move-result-object v2

        const-string v3, "&"

        invoke-virtual {v2, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

        .line 324
        invoke-virtual {v1, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

        move-result-object v0

        const-string v2, "&"

        invoke-virtual {v0, v2}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

        .line 325
        invoke-interface {p2}, Ljava/util/Map;->keySet()Ljava/util/Set;

        move-result-object v0

        invoke-interface {v0}, Ljava/util/Set;->iterator()Ljava/util/Iterator;

        move-result-object v2

        :cond_0
        :goto_1
        invoke-interface {v2}, Ljava/util/Iterator;->hasNext()Z

        move-result v0

        if-eqz v0, :cond_2

        invoke-interface {v2}, Ljava/util/Iterator;->next()Ljava/lang/Object;

        move-result-object v3

        .line 327
        :try_start_1
        invoke-interface {p2, v3}, Ljava/util/Map;->get(Ljava/lang/Object;)Ljava/lang/Object;

        move-result-object v0

        .line 328
        instance-of v4, v0, Ljava/util/List;

        if-eqz v4, :cond_1

        .line 329
        check-cast v0, Ljava/util/List;

        .line 330
        invoke-interface {v0}, Ljava/util/List;->iterator()Ljava/util/Iterator;

        move-result-object v4

        :goto_2
        invoke-interface {v4}, Ljava/util/Iterator;->hasNext()Z

        move-result v0

        if-eqz v0, :cond_0

        invoke-interface {v4}, Ljava/util/Iterator;->next()Ljava/lang/Object;

        move-result-object v0

        check-cast v0, Ljava/lang/String;

        .line 331
        invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

        move-result-object v5

        const-string v6, "="

        invoke-virtual {v5, v6}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

        move-result-object v5

        invoke-static {v0}, Lcom/pinterest/api/a/i;->c(Ljava/lang/String;)Ljava/lang/String;

        move-result-object v0

        invoke-virtual {v5, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

        move-result-object v0

        const-string v5, "&"

        invoke-virtual {v0, v5}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

        goto :goto_2

        .line 338
        :catch_0
        move-exception v0

        goto :goto_1

        :catch_1
        move-exception v0

        move-object v0, p1

        goto :goto_0

        .line 334
        :cond_1
        invoke-virtual {v1, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/Object;)Ljava/lang/StringBuilder;

        move-result-object v3

        const-string v4, "="

        invoke-virtual {v3, v4}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

        move-result-object v3

        check-cast v0, Ljava/lang/String;

        invoke-static {v0}, Lcom/pinterest/api/a/i;->c(Ljava/lang/String;)Ljava/lang/String;

        move-result-object v0

        invoke-virtual {v3, v0}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;

        move-result-object v0

        const-string v3, "&"

        invoke-virtual {v0, v3}, Ljava/lang/StringBuilder;->append(Ljava/lang/String;)Ljava/lang/StringBuilder;
        :try_end_1
        .catch Ljava/io/UnsupportedEncodingException; {:try_start_1 .. :try_end_1} :catch_0

        goto :goto_1

        .line 342
        :cond_2
        invoke-virtual {v1}, Ljava/lang/StringBuilder;->toString()Ljava/lang/String;

        move-result-object v0

        invoke-virtual {v1}, Ljava/lang/StringBuilder;->length()I

        move-result v1

        add-int/lit8 v1, v1, -0x1

        invoke-virtual {v0, v7, v1}, Ljava/lang/String;->substring(II)Ljava/lang/String;

        move-result-object v1

        .line 343
        const-string v0, ""

        .line 346
        :try_start_2
        new-instance v2, Ljavax/crypto/spec/SecretKeySpec;

        sget-object v3, Lcom/pinterest/api/a;->f:Ljava/lang/String;

        const-string v4, "UTF-8"

        invoke-virtual {v3, v4}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B

        move-result-object v3

        const-string v4, "HMACSHA256"

        invoke-direct {v2, v3, v4}, Ljavax/crypto/spec/SecretKeySpec;-><init>([BLjava/lang/String;)V

        .line 348
        const-string v3, "HMACSHA256"

        invoke-static {v3}, Ljavax/crypto/Mac;->getInstance(Ljava/lang/String;)Ljavax/crypto/Mac;

        move-result-object v3

        .line 349
        invoke-virtual {v3, v2}, Ljavax/crypto/Mac;->init(Ljava/security/Key;)V

        .line 350
        const-string v4, "LOGGING: MESSAGE"
        invoke-static {v4, v0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
        const-string v2, "UTF-8"

        invoke-virtual {v1, v2}, Ljava/lang/String;->getBytes(Ljava/lang/String;)[B

        move-result-object v1

        invoke-virtual {v3, v1}, Ljavax/crypto/Mac;->doFinal([B)[B

        move-result-object v1

        .line 351
        new-instance v2, Ljava/lang/String;

        invoke-static {v1}, Lorg/apache/commons/codec/binary/Hex;->encodeHex([B)[C

        move-result-object v1

        invoke-direct {v2, v1}, Ljava/lang/String;-><init>([C)V

        const-string v1, " "

        const-string v3, ""

        invoke-virtual {v2, v1, v3}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

        move-result-object v1

        const-string v2, "<"

        const-string v3, ""

        invoke-virtual {v1, v2, v3}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;

        move-result-object v1

        const-string v2, ">"

        const-string v3, ""

        invoke-virtual {v1, v2, v3}, Ljava/lang/String;->replace(Ljava/lang/CharSequence;Ljava/lang/CharSequence;)Ljava/lang/String;
        :try_end_2
        .catch Ljava/lang/Exception; {:try_start_2 .. :try_end_2} :catch_2

        move-result-object v0

        .line 357
        :goto_3
        const-string v1, "oauth_signature=%s"

        new-array v2, v8, [Ljava/lang/Object;

        aput-object v0, v2, v7

        invoke-static {v1, v2}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

        move-result-object v0

        .line 358
        const-string v1, "%s&%s"

        const/4 v2, 0x2

        new-array v2, v2, [Ljava/lang/Object;

        aput-object p1, v2, v7

        aput-object v0, v2, v8

        invoke-static {v1, v2}, Ljava/lang/String;->format(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String;

        move-result-object v0

        return-object v0

        .line 353
        :catch_2
        move-exception v1

        invoke-virtual {v1}, Ljava/lang/Exception;->printStackTrace()V

        goto :goto_3
    .end method
```

  From this code, I can only guess they use HMACSHA256 for generate their signature.

  They will use CLIENT_SECRET as key for the sha algorithm. We only need to know what they use as message

  Search `.line 350`, this is the message will be pass to sha1 algorithm. Again, we add these two line

```smali
    const-string v4, "LOGGING: MESSAGE"
    invoke-static {v4, v1}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I
```

  This will print for us the format of message Pinterest use.

  Now run the pinterest app again, we will see the format of that message

```bash
  POST&https%3A%2F%2Fapi.pinterest.com%2Fv3%2Flogin%2F&client_id=1431602&password=k&timestamp=1395914520&username_or_email=trungkien2288%40gmail.com
```

  Here is the code I use to simulate request in python

```python

    import unittest
    import urllib
    import hashlib
    import hmac

    client_secret = '492124fd20e80e0f678f7a03344875f9b6234e2b'
    client_id = '1431602'


    def generate_signature(method, url, data):
        data['client_id'] = client_id
        sorted_keys = sorted(data.keys())
        message = '&'.join(["%s=%s" % (k, urllib.quote_plus(data[k])) for k in sorted_keys])
        message = "%s&%s&%s" % (method.upper(), urllib.quote_plus(url), message)
        signature = hmac.new(client_secret, message.encode('utf-8'), hashlib.sha256).hexdigest()
        return signature


    class TestCase(unittest.TestCase):

        def test_generate_signature_1(self):
            data = {
                'username_or_email': 'trungkien2288@gmail.com',
                'password': 'k',
                'timestamp': '1395914520'
            }
            url = 'https://api.pinterest.com/v3/login/'

            signature = generate_signature("POST", url, data)
            self.assertEquals(signature, '6ee35c775b5f92668530d9cc2b91d9380c4bf01f1b17ccfa73ecfd2867b7b562')

        def test_generate_signature_2(self):
            data = {
                'timestamp': '1395914294'
            }
            url = 'https://api.pinterest.com/v3/callback/post_install/'

            signature = generate_signature("GET", url, data)
            self.assertEquals(signature, '0783e2deb355326bb998876387445f2d20bafefc930762cb216e4bc6a2ed748e')
```
