---
categories:
- programming
- python
- django
- tastypie
comments: true
date: 2012-10-16T00:00:00Z
title: Authentication django-tastypie in right way
url: /blog/2012/10/16/authenticated-django-tastypie-in-right-way.html
---

When using django-tastypie, I got some problems with security.
In my pinterest-clone application, I build a pin model.
A `pin` is a image with a description and tags for it`

<!--more-->

I want to build API for that model with some constrains:

+ Everyone can see pins of other people
+ Only author of pin can delete/modify his owner pin, other people are not allow
to do this action

So the API should be
```bash
1. Get list pin

* HTTP Method: GET
* URL endpoint: http://<domain>/api/pin/
* Return:
    [
      objects : [{
        <pin infomation>
      }]
    ]

2. Delete a pin
* HTTP Method: DELETE
* URL endpoint: http://<domain>/api/pin/<pin_id>/
* Return:
    + { "error": "Pin not found" } if dont have <pin_id> in database
    + { "error": "Authorization error" } if user request this API is not owner of <pin_id>
    + Nothing if delete pin successfully

3. Modify a pin
* HTTP Method: DELETE
* URL endpoint: http://<domain>/api/pin/<pin_id>/
* POST params:
    {
        "description": <string>
        "tags": List of string
    }
* Return:
    + { "error": "Pin not found" } if dont have <pin_id> in database
    + { "error": "Authorization error" } if user request this API is not owner of <pin_id>
    + Nothing if modify pins successful
```


To solve security issue with django-tastypie, I subclass `tastypie.authorization.Authorization` class.
And modify the method `apply_limits` in this custom class

Here is the source code

```python
from tastypie.resources import ModelResource
from tastypie.exceptions import BadRequest
from tastypie.serializers import Serializer
from tastypie.authorization import Authorization

from django.contrib.auth.models import User

from pinry.pins.models import Pin
from pinry.pins.models import Like
from pinry.pins.models import Comment
from pinry.core.models import Member

class PinAuthorization(Authorization):
    def is_authorized(self, request, object=None):
        # only logged in user will can modify pins
        if request.method in ("DELETE", "PUT"):
            if not request.user.is_authenticated():
                raise BadRequest(json.dumps({"error": "Authorization error"}))
        return True

    def apply_limits(self, request, object_list=None):
        # only allow delete/modify pin belong to this user
        if request.method in ("DELETE", "PUT"):
            filter_list = object_list.filter(submitter=request.user.get_profile())
            if not filter_list:
                raise BadRequest(json.dumps({"error": "Authorization error"}))
            return filter_list

        return object_list


class PinResource(ModelResource):
    class Meta:
        queryset = Pin.objects.all()
        resource_name = 'pin'
        list_allowed_method = ["GET"]
        details_allowd_method = ["GET", "PUT", "DELETE"]
        include_resource_uri = False
        authorization = PinAuthorization()
        serializer = Serializer(["json"])
        filtering = {
            'published': ['gt'],
        }
```

There are some note in my code:

1. In PinResource class, i only accept GET method for list request
  and GET, PUT, DELETE for detail method
2. I set default serializer is json format, so i dont need pass paramter format=json
  in every request
3. To return error in response, i raise BadRequest exception in 2 functions `is_authorized`
and `apply_limits`. Type of exception (**BadRequest**) is very important because tastypie
only handle that exception when process your request.

Here is the code i got from lastest source code of tastypie on github

```python
# file tastypie/resource class Resource
def wrap_view(self, view):
    """
    Wraps methods so they can be called in a more functional way as well
    as handling exceptions better.

    Note that if ``BadRequest`` or an exception with a ``response`` attr
    are seen, there is special handling to either present a message back
    to the user or return the response traveling with the exception.
    """
    @csrf_exempt
    def wrapper(request, *args, **kwargs):
        try:
            callback = getattr(self, view)
            response = callback(request, *args, **kwargs)

            # Our response can vary based on a number of factors, use
            # the cache class to determine what we should ``Vary`` on so
            # caches won't return the wrong (cached) version.
            varies = getattr(self._meta.cache, "varies", [])

            if varies:
                patch_vary_headers(response, varies)

            if self._meta.cache.cacheable(request, response):
                if self._meta.cache.cache_control():
                    # If the request is cacheable and we have a
                    # ``Cache-Control`` available then patch the header.
                    patch_cache_control(response, **self._meta.cache.cache_control())

            if request.is_ajax() and not response.has_header("Cache-Control"):
                # IE excessively caches XMLHttpRequests, so we're disabling
                # the browser cache here.
                # See http://www.enhanceie.com/ie/bugs.asp for details.
                patch_cache_control(response, no_cache=True)

            return response
        except (BadRequest, fields.ApiFieldError), e:
            return http.HttpBadRequest(e.args[0])
        except ValidationError, e:
            return http.HttpBadRequest(', '.join(e.messages))
        except Exception, e:
            if hasattr(e, 'response'):
                return e.response

            # A real, non-expected exception.
            # Handle the case where the full traceback is more helpful
            # than the serialized error.
            if settings.DEBUG and getattr(settings, 'TASTYPIE_FULL_DEBUG', False):
                raise

            # Re-raise the error to get a proper traceback when the error
            # happend during a test case
            if request.META.get('SERVER_NAME') == 'testserver':
                raise

            # Rather than re-raising, we're going to things similar to
            # what Django does. The difference is returning a serialized
            # error message.
            return self._handle_500(request, e)

    return wrapper
```

`wrap_view` is method was called when tastypie get request from client.

In this code, tastypie only return HttpBadRequest for BadRequest and ApiFieldError
exception, other Exception will handle by 500 internal error request
