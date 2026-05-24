package com.example.backend

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
@SerialName("Dog")
data class Dog(
    override val name: String,
    val bark: Boolean,
    val breed: String
) : Pet(PetType.Dog)
