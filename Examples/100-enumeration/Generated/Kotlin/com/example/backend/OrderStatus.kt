package com.example.backend

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
enum class OrderStatus {
    @SerialName("placed")
    Placed,

    @SerialName("processing")
    Processing,

    @SerialName("shipped")
    Shipped,

    @SerialName("delivered")
    Delivered
}
