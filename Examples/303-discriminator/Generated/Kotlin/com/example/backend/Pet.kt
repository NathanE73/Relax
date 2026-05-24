package com.example.backend

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.JsonClassDiscriminator

@Serializable
@JsonClassDiscriminator("petType")
sealed class Pet(
    val petType: PetType
) {
    abstract val name: String

    @Serializable
    enum class PetType {
        Cat,
        Dog
    }
}
