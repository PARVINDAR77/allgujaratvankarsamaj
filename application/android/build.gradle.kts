allprojects {
    repositories {
        google()
        mavenCentral()
    }
}


subprojects {
    afterEvaluate {
        if (project.extensions.findByName("android") != null) {
            val android = project.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            android?.apply {
                compileSdkVersion(37)
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
