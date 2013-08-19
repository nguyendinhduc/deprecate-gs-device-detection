<#assign project_id="gs-device-detection">
This guide walks you through the process of using Spring to detect the type of device that is accessing your web site.

What you'll build
-----------------

You'll create a Spring MVC application that detects the type of device that is accessing your web site and that switches views dynamically based on that device type.

What you'll need
----------------

 - About 15 minutes
 - <@prereq_editor_jdk_buildtools/>


## <@how_to_complete_this_guide jump_ahead='Create a configuration class'/>


<a name="scratch"></a>
Set up the project
------------------

<@build_system_intro/>

<@create_directory_structure_hello/>

### Create a Gradle build file

    <@snippet path="build.gradle" prefix="initial"/>

<@bootstrap_starter_pom_disclaimer/>


<a name="initial"></a>
Create a configuration class
----------------------------

Use the following configuration class to tell Spring where it can find the endpoint controller class:

    <@snippet path="src/main/java/hello/DeviceDetectionConfiguration.java" prefix="complete"/>

This class subclasses [`WebMvcConfigurerAdapter`], which allows you to customize the configuration of a Spring MVC application. In this case, you add two classes, [`DeviceResolverHandlerInterceptor`] and [`DeviceHandlerMethodArgumentResolver`]. [`DeviceResolverHandlerInterceptor`] is an implementation of a [`HandlerInterceptor`] which, as the name implies, intercepts a request to the application and determines the type of requesting device. After the device is resolved, the [`DeviceHandlerMethodArgumentResolver`] allows Spring MVC to use the resolved [`Device`] object in a controller method.

Under the hood, `DeviceResolverHandlerInterceptor` examines the `User-Agent` header in the incoming request, and based on the header value, determines whether the request is coming from a normal (desktop) browser, a mobile (phone) browser, or a tablet browser. You could, of course, parse the `User-Agent` header yourself to determine if you're dealing with a mobile device or not. But [`User-Agent` sniffing can be tricky](http://googlewebmastercentral.blogspot.co.at/2011/03/mo-better-to-also-detect-mobile-user.html). Therefore, it's better to let `DeviceResolverHandlerInterceptor` handle that for you.


Create a web controller
-----------------------

In Spring, web endpoints are simply Spring MVC controllers. The following Spring MVC controller handles a GET request and returns a String indicating the type of the device:

    <@snippet path="src/main/java/hello/DeviceDetectionController.java" prefix="complete"/>

For this example, rather than rely on a view (such as JSP) to render model data in HTML, this controller simply returns the data to be written directly to the body of the response. In this case, the data is a String that reads "Hello mobile browser!" if the requesting client is a mobile device. The [`@ResponseBody`] annotation tells Spring MVC to write the returned object into the response body, rather than to render a model into a view.


Make the application executable
-------------------------------

Although it is possible to package this service as a traditional [WAR][u-war] file for deployment to an external application server, the simpler approach demonstrated in the next section creates a _standalone application_. You package everything in a single, executable JAR file, driven by a good old Java `main()` method. And along the way, you use Spring's support for embedding the [Tomcat][u-tomcat] servlet container as the HTTP runtime, instead of deploying to an external instance.

### Create an application class

    <@snippet path="src/main/java/hello/Application.java" prefix="complete"/>

The `main()` method defers to the [`SpringApplication`][] helper class, providing `Application.class` as an argument to its `run()` method. This tells Spring to read the annotation metadata from `Application` and to manage it as a component in the _[Spring application context][u-application-context]_.

The `@ComponentScan` annotation tells Spring to search recursively through the `hello` package and its children for classes marked directly or indirectly with Spring's [`@Component`][] annotation. This directive ensures that Spring finds and registers the `DeviceDetectionConfiguration` and `DeviceDetectionController` classes, because they are marked with `@Controller`, which in turn is a kind of `@Component` annotation.

The [`@EnableAutoConfiguration`][] annotation switches on reasonable default behaviors based on the content of your classpath. For example, because the application depends on the embeddable version of Tomcat (tomcat-embed-core.jar), a Tomcat server is set up and configured with reasonable defaults on your behalf. And because the application also depends on Spring MVC (spring-webmvc.jar), a Spring MVC [`DispatcherServlet`][] is configured and registered for you — no `web.xml` necessary! Auto-configuration is a powerful, flexible mechanism. See the [API documentation][`@EnableAutoConfiguration`] for further details.

<@build_an_executable_jar_subhead/>

<@build_an_executable_jar_with_gradle/>

<@run_the_application_with_gradle module="service"/>

Logging output is displayed. The service should be up and running within a few seconds.


Test the service
----------------

To test the application, point your browser at http://localhost:8080/detect-device. In a normal desktop browser, you should see something like this:

![The response for a normal desktop browser](images/normal-browser.png)

If you point a mobile browser at the same URL (such as the iOS Simulator's browser), you should see something like this (you may have to zoom in on the mobile browser to read the message clearly):

![The response for a mobile browser](images/mobile-browser.png)

If you point a tablet browser at the URL, you should see something like this:

![The response for a tablet browser](images/tablet-browser.png)

Note that if you want to use a real mobile device to test this controller, it will not work with the localhost server. You'll need to find the name of your machine on your network and use that instead of localhost.


Summary
-------

Congratulations! You have just developed a simple web page that detects the type of device being used by a client.


<@u_war/>
<@u_tomcat/>
<@u_application_context/>
[`@Configuration`]:http://static.springsource.org/spring/docs/3.2.x/javadoc-api/org/springframework/context/annotation/Configuration.html
[`WebMvcConfigurerAdapter`]:http://static.springsource.org/spring/docs/3.2.x/javadoc-api/org/springframework/web/servlet/config/annotation/WebMvcConfigurerAdapter.html
[`DeviceResolverHandlerInterceptor`]:http://static.springsource.org/spring-mobile/docs/1.1.x/api/org/springframework/mobile/device/DeviceResolverHandlerInterceptor.html
[`DeviceHandlerMethodArgumentResolver`]:http://static.springsource.org/spring-mobile/docs/1.1.x/api/org/springframework/mobile/device/DeviceHandlerMethodArgumentResolver.html
[`HandlerInterceptor`]:http://static.springsource.org/spring/docs/3.2.x/javadoc-api/org/springframework/web/servlet/HandlerInterceptor.html
[`Device`]:http://static.springsource.org/spring-mobile/docs/1.1.x/api/org/springframework/mobile/device/Device.html
[`@Component`]: http://static.springsource.org/spring/docs/current/javadoc-api/org/springframework/stereotype/Component.html
[`@ResponseBody`]:http://static.springsource.org/spring/docs/3.2.x/javadoc-api/org/springframework/web/bind/annotation/ResponseBody.html
[`SpringApplication`]: http://static.springsource.org/spring-bootstrap/docs/0.5.0.BUILD-SNAPSHOT/javadoc-api/org/springframework/bootstrap/SpringApplication.html
[`DispatcherServlet`]: http://static.springsource.org/spring/docs/current/javadoc-api/org/springframework/web/servlet/DispatcherServlet.html
[`@EnableAutoConfiguration`]: http://static.springsource.org/spring-bootstrap/docs/0.5.0.BUILD-SNAPSHOT/javadoc-api/org/springframework/bootstrap/context/annotation/SpringApplication.html
