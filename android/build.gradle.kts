buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // ESTA LÍNEA DEBE SER AÑADIDA para que Gradle pueda encontrar el plugin
        classpath("com.google.gms:google-services:4.4.2") // Usa esta versión o la más reciente.
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
