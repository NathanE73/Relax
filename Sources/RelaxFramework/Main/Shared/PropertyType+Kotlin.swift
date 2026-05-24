//
// Copyright (c) 2026 Nathan E. Walczak
//
// MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation

extension PropertyType {
    func kotlinName(for framework: Platform.KotlinFramework) -> String {
        switch (self, framework) {
        case (.bool, _): "Boolean"
        case (.date, _): "OffsetDateTime"
        case (.double, .kotlinx): "BigDecimal"
        case (.double, .moshi): "Double"
        case (.float, _): "Float"
        case (.int, _): "Int"
        case (.int32, _): "Int"
        case (.int64, _): "Long"
        case let (.object(object), _): object
        case (.string, _): "String"
        }
    }

    func kotlinImportName(for framework: Platform.KotlinFramework) -> String? {
        switch (self, framework) {
        case (.bool, _): nil
        case (.date, _): "java.time"
        case (.double, .kotlinx): "java.math"
        case (.double, .moshi): nil
        case (.float, _): nil
        case (.int, _): nil
        case (.int32, _): nil
        case (.int64, _): nil
        case (.object, _): nil
        case (.string, _): nil
        }
    }
}
