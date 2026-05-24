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

    @Serializable
    @SerialName("Cat")
    data class Cat(
        override val name: String,
        val meow: Boolean,
        val lives: Int
    ) : Pet(PetType.Cat)

    @Serializable
    @SerialName("Dog")
    data class Dog(
        override val name: String,
        val bark: Boolean,
        val breed: String
    ) : Pet(PetType.Dog)
}
