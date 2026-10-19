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

    // These super_clipboard libraries hard-code API 31, which is too old for
    // the AndroidX dependencies supplied by current Flutter versions.
    if (name in setOf("irondash_engine_context", "super_native_extensions")) {
        plugins.withId("com.android.library") {
            extensions.configure<com.android.build.api.variant.LibraryAndroidComponentsExtension> {
                finalizeDsl { library ->
                    val appCompileSdk = project(":app")
                        .extensions.getByType<com.android.build.api.dsl.ApplicationExtension>()
                        .compileSdk
                    library.compileSdk = maxOf(
                        library.compileSdk ?: 0,
                        requireNotNull(appCompileSdk),
                    )
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
