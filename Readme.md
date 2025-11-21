## Maven Multi-Module Project Structure & POM Roles

### 1. Global POM (`ai_news_platform/pom.xml`)
- Acts as the parent for all modules.
- Manages shared dependencies, plugins, and properties (e.g., Java version, Spring Cloud version).
- Uses `<dependencyManagement>` to import the Spring Cloud BOM:
	```xml
	<dependencyManagement>
		<dependencies>
			<dependency>
				<groupId>org.springframework.cloud</groupId>
				<artifactId>spring-cloud-dependencies</artifactId>
				<version>${spring-cloud.version}</version>
				<type>pom</type>
				<scope>import</scope>
			</dependency>
		</dependencies>
	</dependencyManagement>
	```
- Ensures all modules use consistent dependency versions.
- Should NOT use `spring-boot-starter-parent` as parent; only one parent is allowed, and it should be your global POM.

### 2. Module POMs (e.g., `config_server/pom.xml`)
- Each module POM sets its parent to the global POM:
	```xml
	<parent>
		<groupId>com.sg_tech</groupId>
		<artifactId>ai_news_platform</artifactId>
		<version>0.0.1-SNAPSHOT</version>
		<relativePath>../pom.xml</relativePath>
	</parent>
	```
- Only declare module-specific dependencies (e.g., `spring-cloud-config-server`).
- Do NOT use `spring-boot-starter-parent` as parent in modules; this causes conflicts and breaks inheritance.

### 3. What is BOM?
- BOM (Bill of Materials) is a special POM that manages versions for a set of dependencies.
- Used in `<dependencyManagement>` to ensure all Spring Cloud dependencies use compatible versions.
- Example: `spring-cloud-dependencies` BOM.

### 4. Why not use `spring-boot-starter-parent` in modules?
- Only one parent POM is allowed; using `spring-boot-starter-parent` in modules breaks the multi-module structure.
- The global POM should handle all shared configuration and version management.
- Use the BOM in `<dependencyManagement>` for Spring Boot and Spring Cloud version alignment.

### 5. Dependency Management
- Global POM manages versions via BOM.
- Modules only declare the dependencies they need; versions are inherited from the BOM.

### 6. Summary of Roles
- **Global POM:** Centralized management, version alignment, plugin configuration.
- **Module POM:** Inherits from global, declares only what is needed for the module.
- **BOM:** Ensures consistent versions for related dependencies.

---
For more details, see the official Spring Boot and Spring Cloud documentation on multi-module Maven projects.


## Run the AI_NEWS_PLATFORM in default profile
```bash
run_app_default.sh
```
