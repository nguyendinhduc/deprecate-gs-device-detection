# Getting Started: Device Detection on the Web

This Getting Started guide will walk you through the process of detecting the type of device accessing your web site using Spring.

To help you get started, we've provided an initial project structure as well as the completed project for you in GitHub:

```sh
$ git clone https://github.com/springframework-meta/gs-device-detection-web.git
```

In the `start` folder, you'll find a bare project, ready for you to copy and paste code snippets from this document. In the `complete` folder, you'll find the complete project code.

Before we can write the Web controller itself, there's some initial project setup that's required. Or, you can skip straight to the [fun part](#creating-a-representation-class).


## Selecting Dependencies

The sample in this Getting Started Guide will leverage Spring MVC and Spring Mobile. Therefore, the following library dependencies are needed in the project's build configuration:

  - org.springframework:spring-webmvc:3.2.2.RELEASE
  - org.springframework.mobile:spring-mobile-device:1.1.0.M3

Refer to the [Gradle Getting Started Guide] or the [Maven Getting Started Guide] for details on how to include these dependencies in your build.


## Setting Up DispatcherServlet

Device detection can be utilized within Spring MVC controllers. Therefore, we will need to be sure that Spring's [`DispatcherServlet`] is configured. We can do that by creating a web application initializer class:

```java
package hello;

import org.springframework.web.servlet.support.AbstractAnnotationConfigDispatcherServletInitializer;

public class HelloWorldWebAppInitializer extends AbstractAnnotationConfigDispatcherServletInitializer {

	@Override
	protected String[] getServletMappings() {
		return new String[] { "/" };
	}

	@Override
	protected Class<?>[] getRootConfigClasses() {
		return null;
	}

	@Override
	protected Class<?>[] getServletConfigClasses() {
		return new Class[] { HelloWorldConfiguration.class };
	}

}
```

By extending [`AbstractAnnotationConfigDispatcherServletInitializer`], our web application initializer will get a [`DispatcherServlet`] that is configured with [`@Configuration`]-annotated classes. All we must do is tell it where those configuration classes are and what path(s) to map [`DispatcherServlet`] to. 

With regard to the servlet path mappings, `getServletMappings()` returns a single-entry array of `String` specifying that [`DispatcherServlet`] should be mapped to "/".

The `getRootConfigClasses()` and `getServletConfigClasses()` methods specify the configuration classes. The `Class` array returned from `getRootConfigClasses()` specifies the classes for the root context provided to [`ContextLoaderListener`]. Similarly, the `Class` array returned from `getServletConfigClasses()` specifies the classes for the servlet application context provided to [`DispatcherServlet`]. 

For our purposes there will only be a servlet application context, so `getRootConfigClasses()` returns `null`. `getServletConfigClasses()`, however, specifies `HelloWorldConfiguration` as the only configuration class.


## Creating a Configuration Class

Now that we have setup [`DispatcherServlet`] to handle requests for our application, we need to configure the Spring application context used by [`DispatcherServlet`].

In our Spring configuration, we will need to enable annotation-oriented Spring MVC. And we'll also need to tell Spring where it can find our endpoint controller class. The following configuration class takes care of both of those things:

```java
package hello;

import java.util.List;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.mobile.device.DeviceHandlerMethodArgumentResolver;
import org.springframework.mobile.device.DeviceResolverHandlerInterceptor;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurerAdapter;

@Configuration
@EnableWebMvc
@ComponentScan
public class HelloWorldConfiguration extends WebMvcConfigurerAdapter {

	@Override
	public void addInterceptors(InterceptorRegistry registry) {
		registry.addInterceptor(new DeviceResolverHandlerInterceptor());
	}

	@Override
	public void addArgumentResolvers(List<HandlerMethodArgumentResolver> argumentResolvers) {
		argumentResolvers.add(new DeviceHandlerMethodArgumentResolver());
	}

}
```
	
The [`@EnableWebMvc`] annotation turns on annotation-oriented Spring MVC. And we've also annotated the configuration class with [`@ComponentScan`] to have it look for components (including controllers) in the `hello` package.

This class also subclasses [`WebMvcConfigurerAdapter`], which allows us to add some additional configuration to a Spring MVC application. In this case, we are adding two additional components, a [`DeviceResolverHandlerInterceptor`], and [`DeviceHandlerMethodArgumentResolver`]. [`DeviceResolverHandlerInterceptor`] is an implementation of a [`HandlerInterceptor`] which, as the name implies, intercepts a request to the application and determines the type of requesting device. After the device is resolved, the [`DeviceHandlerMethodArgumentResolver`] allows Spring MVC to make use of the resolved [`Device`] object in a controller method.


## Creating a Web Controller

In Spring, web endpoints are just Spring MVC controllers. The following Spring MVC controller handles a GET request and returns a String indicating the type of the device:

```java
package hello;

import org.springframework.mobile.device.Device;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class HelloWorldController {

	@RequestMapping("/")
	public @ResponseBody String home(Device device) {
		String deviceType = "unknown";
		if (device.isNormal()) {
			deviceType = "normal";
		} else if (device.isMobile()) {
			deviceType = "mobile";
		} else if (device.isTablet()) {
			deviceType = "tablet";
		}
		return "Hello " + deviceType + " browser!";
	}

}
```

For this example, rather than rely on a view (such as JSP) to render model data in HTML, this controller simply returns the data to be written directly to the body of the response. In this case, that data is a String which simply reads, "Hello mobile browser!" if the requesting client is a mobile device. This is possible with the use of the [`@ResponseBody`] annotation. [`@ResponseBody`] tells Spring MVC to not render a model into a view, but rather to write the returned object into the response body.


## Building and Running the REST Service

>**NOTE**: This section is a very important section, because it shows the user how all of the work done up to this point comes together and runs. The challenge here, however, is that there's no *easy* way to run this application. Gradle's Jetty plugin seems easy and natural, but it uses an older, non-Servlet 3 version of Jetty, so the application initializer will not work. There is a Gradle Tomcat plugin, but it's quite involved setup-wise. And loading this into any IDE and running it is far more involved than either of the Gradle-based options. It would be really nice to leverage Spring Bootstrap/Catalyst for running the sample. That's likely what will happen, but at this point it's too risky of an option until bootstrap/catalyst stabilizes.


## Next Steps

Congratulations! You have just developed a simple web page that detects the type of device being used by the client.

There's more to handling different device types than is covered here. You may want to continue your exploration of Spring with the following Getting Started guides:

* Remembering a User's Preferred Site
* Testing web endpoints



[`DispatcherServlet`]:http://static.springsource.org/spring/docs/3.2.x/javadoc-api/org/springframework/web/servlet/DispatcherServlet.html
[`AbstractAnnotationConfigDispatcherServletInitializer`]:http://static.springsource.org/spring/docs/3.2.x/javadoc-api/org/springframework/web/servlet/support/AbstractAnnotationConfigDispatcherServletInitializer.html
[`@Configuration`]:http://static.springsource.org/spring/docs/3.2.x/javadoc-api/org/springframework/context/annotation/Configuration.html
[`ContextLoaderListener`]:http://static.springsource.org/spring/docs/3.2.x/javadoc-api/org/springframework/web/context/ContextLoaderListener.html
[`@EnableWebMvc`]:http://static.springsource.org/spring/docs/3.2.x/javadoc-api/org/springframework/web/servlet/config/annotation/EnableWebMvc.html
[`@ComponentScan`]:http://static.springsource.org/spring/docs/3.2.x/javadoc-api/org/springframework/context/annotation/ComponentScan.html
[`WebMvcConfigurerAdapter`]:http://static.springsource.org/spring/docs/3.2.x/javadoc-api/org/springframework/web/servlet/config/annotation/WebMvcConfigurerAdapter.html
[`DeviceResolverHandlerInterceptor`]:http://static.springsource.org/spring-mobile/docs/1.1.x/api/org/springframework/mobile/device/DeviceResolverHandlerInterceptor.html
[`DeviceHandlerMethodArgumentResolver`]:http://static.springsource.org/spring-mobile/docs/1.1.x/api/org/springframework/mobile/device/DeviceHandlerMethodArgumentResolver.html
[`HandlerInterceptor`]:http://static.springsource.org/spring/docs/3.2.x/javadoc-api/org/springframework/web/servlet/HandlerInterceptor.html
[`Device`]:http://static.springsource.org/spring-mobile/docs/1.1.x/api/org/springframework/mobile/device/Device.html
[`@ResponseBody`]:http://static.springsource.org/spring/docs/3.2.x/javadoc-api/org/springframework/web/bind/annotation/ResponseBody.html
