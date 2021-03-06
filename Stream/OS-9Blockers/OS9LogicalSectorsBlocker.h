//
//  OS9LogicalSectorsBlocker.h
//  Stream
//
//  Created by tim lindner on 5/5/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Blockers.h"
#import "StStream.h"
#import "AppDelegate.h"

@interface OS9LogicalSectorsBlocker : Blockers

@end

@interface OS9StringTransformer : NSValueTransformer
{
}
- (id)reverseTransformedValue:(id)value ofSize:(size_t)size;
@end

@interface OS9DateTransformer : NSValueTransformer
{
}
- (id)reverseTransformedValue:(id)value ofSize:(size_t)size;
@end
