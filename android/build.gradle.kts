plugins {
    // Make sure you have IDs for existing plugins like these (versions might differ)
    id("com.android.application") apply false
    id("org.jetbrains.kotlin.android") apply false
    id("com.google.firebase.crashlytics") version "2.9.9" apply false // Use the latest compatible version
    id("com.google.gms.google-services") apply false
}


allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
