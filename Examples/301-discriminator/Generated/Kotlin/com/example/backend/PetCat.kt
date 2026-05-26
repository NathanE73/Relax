package com.example.backend

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
@SerialName("cat")
data class PetCat(
    override val name: String,
    val meow: Boolean,
    val lives: Int
) : Pet(PetType.Cat)
